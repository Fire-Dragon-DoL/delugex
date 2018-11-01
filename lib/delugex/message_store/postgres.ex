defmodule Delugex.MessageStore.Postgres do
  @moduledoc """
  This is the real implementation of MessageStore. It will execute the needed
  queries on Postgres through Postgrex by calling the functions provided in
  [ESP](https://github.com/Carburetor/ESP/tree/master/app/config/functions/stream). You should be able to infer what to write, it's just passing the
  required arguments to the SQL functions and converting any returned value.
  Whenever a stream name is expected, please use the %StreamName struct and
  make sure to convert it to string.
  """

  use Delugex.MessageStore

  import Delugex.MessageStore,
    only: [
      is_version: 1,
      is_expected_version: 1,
      is_batch_size: 1
    ]

  alias Delugex.StreamName
  alias Delugex.Event
  alias Delugex.Event.Raw
  alias Delugex.Event.Metadata
  alias Delugex.MessageStore.Postgres.Repo

  @wrong_version "Wrong expected version:"

  @stream_read_batch_sql """
  select * from get_stream_messages(
    _stream_name := $1,
    _position    := $2,
    _batch_size  := $3
  )
  """
  @category_read_batch_sql """
  select * from get_category_messages(
    _stream_name := $1,
    _position    := $2,
    _batch_size  := $3
  )
  """
  @stream_read_last_sql "select * from get_last_message(_stream_name := $1)"
  @write_sql """
  select * from write_message(
    _id               := $1::uuid,
    _stream_name      := $2,
    _type             := $3,
    _data             := $4,
    _metadata         := $5,
    _expected_version := $6
  )
  """
  @version_sql "select * from stream_version(_stream_name := $1)"

  @impl Delugex.MessageStore
  @doc """
  Write has an optional expected_version argument. This argument could be one of:
  - nil: no version expected
  - no_stream: no message ever written to this stream, the Postgres
    stream_version position will return null (max(position) is null if no rows
    are present)
  - An integer (0+): Representing the expected version
  """
  def write!(%Event{} = event, expected_version \\ nil)
      when is_expected_version(expected_version) do
    expected_version = to_number_version(expected_version)
    params = encode_event(event)
    params = params ++ [expected_version]

    query(@write_sql, params).rows
    |> rows_to_single_result
  rescue
    error in Postgrex.Error -> as_known_error!(error)
  end

  @impl Delugex.MessageStore
  @doc """
  - `events` list of events to write
  - `stream_name` stream where events will be written to (will overwrite
    any stream_name provided in the events)
  - optional `expected_version` argument. This argument could be one of:
    - `nil`: no version expected
    - `:no_stream`: no message ever written to this stream, the Postgres
      stream_version position will return null (max(position) is null if no
      rows are present)
    - An integer (0+): Representing the expected version
  """
  def write_batch!(
        events,
        stream_name,
        expected_version \\ nil
      )
      when is_list(events) and is_expected_version(expected_version) do
    insertables =
      events
      |> Stream.map(fn event -> Map.put(event, :stream_name, stream_name) end)
      |> Stream.with_index()
      |> Stream.map(fn {event, index} ->
        case index do
          0 -> {event, to_number_version(expected_version)}
          _ -> {event, nil}
        end
      end)

    Repo.transaction(fn ->
      Enum.reduce(insertables, nil, fn {event, expected_version} ->
        write!(event, expected_version)
      end)
    end)
  end

  @impl Delugex.MessageStore
  @doc """
  Retrieve's the last stream by the stream_name (based on greatest position).
  """
  def read_last(stream_name) do
    stream_name = StreamName.to_string(stream_name)

    query(@stream_read_last_sql, [stream_name]).rows
    |> rows_to_events
    |> List.last()
  end

  @impl Delugex.MessageStore
  @doc """
  Retrieve steams by the stream_name, in batches of 10 by default.
  """
  def read_batch(stream_name, position \\ 0, batch_size \\ 10)
      when is_version(position) and is_batch_size(batch_size) do
    stream_name = StreamName.to_string(stream_name)

    sql =
      case StreamName.category?(stream_name) do
        true -> @category_read_batch_sql
        false -> @stream_read_batch_sql
      end

    query(sql, [stream_name, position, batch_size]).rows
    |> rows_to_events
  end

  @impl Delugex.MessageStore
  @doc """
  Retrieves the last message position, or :no_stream if none are present
  """
  def read_version(stream_name) do
    stream_name = StreamName.to_string(stream_name)

    version =
      query(@version_sql, [stream_name]).rows
      |> rows_to_single_result

    case version do
      nil -> :no_stream
      _ -> version
    end
  end

  @impl Delugex.MessageStore
  @doc """
  Receives notifications as GenServer casts. Two types of notifications are
  received:

  - `{:notification, connection_pid, ref, channel, payload}` with a notify
    from Postgres (check
    [Postgrex documentation](https://hexdocs.pm/postgrex/Postgrex.Notifications.html#listen/3))
  - `{:reminder}` which is received every X seconds
  """
  def listen(stream_name, opts \\ []) do
    stream_name = StreamName.to_string(stream_name)
    Repo.listen(stream_name, opts)
  end

  @impl Delugex.MessageStore
  @doc """
  Stops notifications
  """
  def unlisten(ref, opts \\ []) do
    Repo.unlisten(ref, opts)
  end

  defp to_number_version(:no_stream), do: -1
  defp to_number_version(nil), do: nil
  defp to_number_version(expected_version), do: expected_version

  defp query(raw_sql, parameters) do
    Repo
    |> Ecto.Adapters.SQL.query!(raw_sql, parameters)
  end

  defp encode_event(%Event{
         id: id,
         stream_name: stream_name,
         type: type,
         data: data,
         metadata: metadata
       }) do
    id = cast_uuid_to_uuid(id)
    stream_name = StreamName.to_string(stream_name)

    [id, stream_name, type, data, metadata]
  end

  defp rows_to_single_result([[value]]), do: value

  defp rows_to_events(rows) do
    rows
    |> Enum.map(&row_to_event_raw/1)
  end

  defp row_to_event_raw([
         id,
         stream_name,
         type,
         position,
         global_position,
         data,
         metadata,
         time
       ]) do
    id = cast_uuid_as_string(id)

    %Raw{
      id: decode_id(id),
      stream_name: decode_stream_name(stream_name),
      type: type,
      position: position,
      global_position: global_position,
      data: decode_data(data),
      metadata: decode_metadata(metadata),
      time: decode_naive_date_time(time)
    }
  end

  defp symbolize(map) do
    map
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  defp as_known_error!(error) do
    message = to_string(error.postgres.message)

    cond do
      String.starts_with?(message, @wrong_version) ->
        raise Delugex.MessageStore.ExpectedVersionError, message: message

      true ->
        raise error
    end
  end

  defp cast_uuid_to_uuid(id) do
    {:ok, uuid} =
      id
      |> Ecto.UUID.cast!()
      |> Ecto.UUID.dump()

    uuid
  end

  defp cast_uuid_as_string(id) do
    Ecto.UUID.cast!(id)
  end

  defp decode_stream_name(text_stream_name) do
    adapter =
      __MODULE__
      |> Application.get_env()
      |> Keyword.fetch!(:stream_name)
      |> Keyword.fetch!(:decoder)
  end

  defp decode_metadata(map) do
    metadata = symbolize(map)
    struct(Metadata, metadata)
  end

  defp decode_data(map) do
    symbolize(map)
  end

  defp decode_naive_date_time(time) do
    NaiveDateTime.from_iso8601!(time)
  end

  defp decode_id(id) do
    cast_uuid_as_string(id)
  end
end
