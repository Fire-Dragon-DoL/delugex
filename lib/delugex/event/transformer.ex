defmodule Delugex.Event.Transformer do
  @moduledoc false

  alias Delugex.RawEvent
  alias Delugex.StreamName

  def to_raw_event(event) when is_map(event) do
    to_raw_event(event, %RawEvent{})
  end

  @spec to_raw_event(
          event :: struct(),
          raw_event_base :: Delugex.RawEvent.t()
        ) :: Delugex.RawEvent.t()
  def to_raw_event(event, %RawEvent{} = raw_event_base) when is_map(event) do
    id = raw_event_base.id || random_uuid()
    time = raw_event_base.time || naive_datetime_now()
    stream_name = raw_event_base.stream_name
    type = raw_event_base.type || Delugex.Event.type(event)

    raw_event =
      raw_event_base
      |> Map.put(:id, id)
      |> Map.put(:stream_name, stream_name)
      |> Map.put(:type, type)
      |> Map.put(:data, Map.from_struct(event))
      |> Map.put(:time, time)

    Delugex.Logger.debug(fn ->
      "Event #{inspect(event)} converted to #{inspect(raw_event)}"
    end)

    raw_event
  end

  @spec to_raw_event(
          event :: struct(),
          stream_name :: Delugex.StreamName.t()
        ) :: Delugex.RawEvent.t()
  def to_raw_event(event, %StreamName{} = stream_name) when is_map(event) do
    raw_event_base = %RawEvent{stream_name: stream_name}

    to_raw_event(event, raw_event_base)
  end

  defp random_uuid do
    UUID.uuid4()
  end

  defp naive_datetime_now do
    DateTime.utc_now()
    |> DateTime.to_naive()
  end
end
