defmodule EspEx.EventBus.Postgres do
  use EspEx.EventBus

  @moduledoc """
  This is the real implementation of EventBus. It will execute the needed
  queries on Postgres through Postgrex by calling the functions provided in
  [ESP](https://github.com/Carburetor/ESP/tree/master/app/config/functions/stream). You should be able to infer what to write, it's just passing the
  required arguments to the SQL functions and converting any returned value.
  Whenever a stream name is expected, please use the %StreamName struct and
  make sure to convert it to string.
  """

  @doc """
    Retrieve steams by the stream_name, in batches of 10 by default.
  """
  def get_batch(name, opts \\ []) do
    sql = """
    select * from stream_get_batch(
    _stream_name := $1, _position := $2, _batch_size  := $3 
    )
    """

    query(sql, [name, opts[:position] || 0, opts[:batch_size] || 10]).rows
    |> rows_to_streams
  end

  @doc """
    Retrieve's the last stream by the stream_name (based on greatest position).
  """
  @spec get_last(binary) :: map
  def get_last(stream_name) do
    sql = "select * from stream_get_last(_stream_name := $1)"

    query(sql, [stream_name]).rows
    |> rows_to_streams
  end

  @doc """
  Write has an optional expected_version argument. This argument could be one of:
  - nil: no version expected 
  - no_stream: no message ever written to this stream, the Postgres
    stream_version position will return null (max(position) is null if no rows
    are present)
  - An integer (0+): Representing the expected version
  """
  # @spec(binary, binary, binary, map, map, integer | :no_stream) :: :ok
  def write(id, stream_name, type, data, opts \\ []) do
    sql = """
     select * from stream_write_message(
       _id               := $1,
       _stream_name      := $2,
       _type             := $3,
       _data             := $4,
       _metadata         := $5,
       _expected_version := $6
    )
    """

    expected_version =
      case opts[:expected_version] do
        value when value == :no_stream ->
          -1

        value when is_integer(value) and value >= 0 ->
          value

        value when is_nil(value) ->
          nil
      end

    query(sql, [id, stream_name, type, data, opts[:metadata] || nil, expected_version])
    :ok
  end

  ################################################################################  

  # @spec query(binary, maybe_improper_list(binary, integer, map)) :: :ok
  defp query(raw_sql, parameters) do
    Ecto.Adapters.SQL.query!(EspEx.Repo, raw_sql, parameters)
  end

  # TODO are we calling these messages? streams? events?
  defp rows_to_streams(rows) do
    for row <- rows do
      [id, stream_name, type, position, global_position, data, metadata, time] = row

      %{
        id: id,
        stream_name: stream_name,
        type: type,
        position: position,
        global_position: global_position,
        data: data,
        metadata: metadata,
        time: time
      }
    end
  end
end
