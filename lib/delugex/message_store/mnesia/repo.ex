defmodule Delugex.MessageStore.Mnesia.Repo do
  @moduledoc false

  alias :mnesia, as: Mnesia
  alias Delugex.StreamName
  alias Delugex.MessageStore.Mnesia.ExpectedVersionError

  def create do
    with {:atomic, _} <-
           Mnesia.create_table(
             Message,
             attributes: [
               :id,
               :stream_category,
               :stream_id,
               :stream,
               :stream_position,
               :stream_global_position,
               :stream_all_position,
               :type,
               :position,
               :global_position,
               :data,
               :metadata,
               :time
             ],
             index: [
               :stream_category,
               :stream_id,
               :stream,
               :stream_position,
               :stream_global_position,
               :stream_all_position,
               :position,
               :global_position
             ]
           ),
         {:atomic, _} <-
           Mnesia.create_table(
             Message.Position,
             attributes: [:stream, :position]
           ),
         {:atomic, _} <-
           Mnesia.create_table(
             Message.Global,
             attributes: [:key, :value]
           ),
         {:atomic, _} <-
           Mnesia.transaction(fn ->
             :ok = Mnesia.write({Message.Global, :global_position, 0})
           end) do
      :ok
    else
      error -> error
    end
  end

  def delete do
    Mnesia.delete_table(Message)
    Mnesia.delete_table(Message.Position)
    Mnesia.delete_table(Message.Global)
    :ok
  end

  def write_message({id, stream_name, type, data, metadata, expected_version}) do
    Mnesia.transaction(fn ->
      Mnesia.write_lock_table(Message)
      Mnesia.write_lock_table(Message.Position)
      Mnesia.write_lock_table(Message.Global)
      {:atomic, version} = stream_version(stream_name)
      {:atomic, global} = new_global_position()
      {:atomic, local} = new_local_position(stream_name)

      case same_version?(version, expected_version) do
        false ->
          Mnesia.abort(%ExpectedVersionError{
            message: "#{expected_version} != #{version}"
          })

        true ->
          stream_category = StreamName.category(stream_name)
          stream_id = StreamName.id(stream_name)

          :ok =
            Mnesia.write({
              Message,
              id,
              stream_category,
              stream_id,
              {stream_category, stream_id},
              {stream_category, stream_id, local},
              {stream_category, stream_id, global},
              {stream_category, stream_id, local, global},
              to_string(type),
              local,
              global,
              encode_json(data),
              encode_json(metadata),
              NaiveDateTime.utc_now()
            })

          local
      end
    end)
  end

  def stream_version(stream_name) do
    Mnesia.transaction(fn ->
      target = to_stream(stream_name)

      case wget({Message.Position, target}) do
        {_, _, current_pos} -> current_pos
        nil -> nil
      end
    end)
  end

  def get_category_messages(category_name, position, batch_size) do
  end

  defp same_version?(_version, nil), do: true
  defp same_version?(nil, -1), do: true

  defp same_version?(version, expected) when is_integer(version) do
    version == expected
  end

  defp new_local_position(stream_name) do
    Mnesia.transaction(fn ->
      target = to_stream(stream_name)

      current_pos =
        case wget({Message.Position, target}) do
          nil -> -1
          {_, _, pos} -> pos
        end

      new_pos = current_pos + 1
      :ok = Mnesia.write({Message.Position, target, new_pos})
      new_pos
    end)
  end

  defp new_global_position do
    Mnesia.transaction(fn ->
      {_, _, current_pos} = wget({Message.Global, :global_position})

      new_pos = current_pos + 1
      :ok = Mnesia.write({Message.Global, :global_position, new_pos})
      new_pos
    end)
  end

  defp to_stream(stream_name) do
    id = StreamName.id(stream_name)
    category = StreamName.category(stream_name)
    {category, id}
  end

  def wget(record, default \\ nil), do: get(record, default, :write)

  def get({tab, key}, default \\ nil, lock \\ :read) do
    case Mnesia.read(tab, key, lock) do
      [] -> default
      [record] -> record
    end
  end

  defp symbolize(map) do
    map
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  defp decode_stream_name(text_stream_name) do
    decoder =
      __MODULE__
      |> Delugex.Config.get(:stream_name, [])
      |> Keyword.get(:decoder, Delugex.Stream.Name)

    decoder.decode(text_stream_name)
  end

  defp decode_metadata(map) do
    metadata =
      map
      |> decode_json()
      |> symbolize()

    struct(Metadata, metadata)
  end

  defp decode_data(map) do
    map
    |> decode_json()
    |> symbolize()
  end

  defp decode_json(text) do
    decoder =
      __MODULE__
      |> Delugex.Config.get(:json, [])
      |> Keyword.get(:decoder, Jason)

    decoder.decode!(text)
  end

  defp encode_json(term) do
    encoder =
      __MODULE__
      |> Delugex.Config.get(:json, [])
      |> Keyword.get(:encoder, Jason)

    encoder.encode!(term)
  end
end
