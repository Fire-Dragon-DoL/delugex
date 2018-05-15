defmodule EspEx.EventBus.Postgres do
  @moduledoc """
  This is the real implementation of EventBus. It will execute the needed
  queries on Postgres through Postgrex by calling the functions provided in
  [ESP](https://github.com/Carburetor/ESP/tree/master/app/config/functions/stream). You should be able to infer what to write, it's just passing the
  required arguments to the SQL functions and converting any returned value.
  Whenever a stream name is expected, please use the %StreamName struct and
  make sure to convert it to string.
  """

  use EspEx.EventBus

  import EspEx.EventBus,
    only: [
      is_version: 1,
      is_expected_version: 1,
      is_batch_size: 1
    ]

  alias EspEx.StreamName
  alias EspEx.RawEvent
  alias EspEx.RawEvent.Metadata

  @get_batch_sql """
  select * from stream_get_batch(
    _stream_name := $1,
    _position    := $2,
    _batch_size  := $3
  )
  """
  @get_last_sql "select * from stream_get_last(_stream_name := $1)"
  @write_message_sql """
  select * from stream_write_message(
    _id               := $1,
    _stream_name      := $2,
    _type             := $3,
    _data             := $4,
    _metadata         := $5,
    _expected_version := $6
  )
  """
  @version_sql "select * from stream_version(_stream_name := $1)"
  @pg_notify_sql "select pg_notify($1, $2)"

  @impl EspEx.EventBus
  @doc """
  Write has an optional expected_version argument. This argument could be one of:
  - nil: no version expected
  - no_stream: no message ever written to this stream, the Postgres
    stream_version position will return null (max(position) is null if no rows
    are present)
  - An integer (0+): Representing the expected version
  """
  def write(%RawEvent{} = raw_event, expected_version \\ nil)
      when is_expected_version(expected_version) do
    query(
      @write_message_sql,
      raw_event_to_params(raw_event) ++ [to_number_version(expected_version)]
    ).rows
    |> rows_to_single_result
  end

  @impl EspEx.EventBus
  @doc """
  Retrieve's the last stream by the stream_name (based on greatest position).
  """
  def read_last(%StreamName{} = stream_name) do
    query(@get_last_sql, [to_string(stream_name)]).rows
    |> rows_to_raw_events
    |> List.last()
  end

  @impl EspEx.EventBus
  @doc """
  Retrieve steams by the stream_name, in batches of 10 by default.
  """
  def read_batch(%StreamName{} = stream_name, position \\ 0, batch_size \\ 10)
      when is_version(position) and is_batch_size(batch_size) do
    query(@get_batch_sql, [to_string(stream_name), position, batch_size]).rows
    |> rows_to_raw_events
  end

  @impl EspEx.EventBus
  @doc """
  Retrieves the last message position, or nil if none are present
  """
  def read_version(%StreamName{} = stream_name) do
    query(@version_sql, [to_string(stream_name)]).rows
    |> rows_to_single_result
  end

  @impl EspEx.EventBus
  @doc """
  Receives notifications as GenServer casts. Two types of notifications are
  received:

  - `{:notification, connection_pid, ref, channel, payload}` with a notify
    from Postgres (check
    [Postgrex documentation](https://hexdocs.pm/postgrex/Postgrex.Notifications.html#listen/3))
  - `{:reminder}` which is received every X seconds
  """
  def listen(%StreamName{} = stream_name, opts \\ []) do
    EspEx.EventBus.Postgres.Notifications.listen(stream_name, opts)
  end

  @impl EspEx.EventBus
  @doc """
  Stops notifications
  """
  def unlisten(ref, opts \\ []) do
    EspEx.EventBus.Postgres.Notifications.unlisten(ref, opts)
  end

  @doc """
  Sends an SQL NOTIFY through postgres
  """
  @spec notify(channel :: String.t(), data :: String.t()) :: :ok
  def notify(channel, data) do
    query(@pg_notify_sql, [channel, data])
    :ok
  end

  defp to_number_version(:no_stream), do: -1
  defp to_number_version(nil), do: nil
  defp to_number_version(expected_version), do: expected_version

  defp query(raw_sql, parameters) do
    EspEx.EventBus.Postgres.Repo
    |> Ecto.Adapters.SQL.query!(raw_sql, parameters)
  end

  defp raw_event_to_params(%RawEvent{
         id: id,
         stream_name: stream_name,
         type: type,
         data: data,
         metadata: metadata
       }) do
    [id, to_string(stream_name), type, data, metadata]
  end

  defp rows_to_single_result([[value]]), do: value

  defp rows_to_raw_events(rows) do
    rows
    |> Enum.map(&row_to_raw_event/1)
  end

  defp row_to_raw_event([
         id,
         stream_name,
         type,
         position,
         global_position,
         data,
         metadata,
         time
       ]) do
    %RawEvent{
      id: id,
      stream_name: StreamName.from_string(stream_name),
      type: type,
      position: position,
      global_position: global_position,
      data: symbolize(data),
      metadata: struct(Metadata, metadata),
      time: time
    }
  end

  defp symbolize(map) do
    map
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end
end
