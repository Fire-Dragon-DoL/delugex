defmodule EspEx.Event do
  @moduledoc """
  Converts a generic event into a RawEvent
  """

  alias EspEx.RawEvent

  @type raw_event_opts :: [
          id: String.t(),
          stream_name: EspEx.StreamName.t(),
          time: NaiveDateTime.t()
        ]

  @spec to_raw_event(
          event :: struct(),
          raw_event_base :: EspEx.RawEvent.t()
        ) :: EspEx.RawEvent.t()
  def to_raw_event(event, %RawEvent{} = raw_event_base)
      when is_map(event) and is_map(raw_event_base) do
    id = raw_event_base.id || random_uuid()
    time = raw_event_base.time || naive_datetime_now()
    stream_name = raw_event_base.stream_name || empty_stream_name()

    type =
      case raw_event_base.type do
        "" -> type(event)
        _ -> raw_event_base.type
      end

    raw_event =
      raw_event_base
      |> Map.put(:id, id)
      |> Map.put(:stream_name, stream_name)
      |> Map.put(:type, type)
      |> Map.put(:data, Map.from_struct(event))
      |> Map.put(:time, time)

    EspEx.Logger.debug(fn ->
      "Event #{inspect(event)} converted to #{inspect(raw_event)}"
    end)

    raw_event
  end

  @spec to_raw_event(
          event :: struct(),
          opts :: raw_event_opts()
        ) :: EspEx.RawEvent.t()
  def to_raw_event(event, opts)
      when is_map(event) and is_list(opts) do
    opts = raw_event_opts(opts)

    raw_event = %RawEvent{
      id: Keyword.get(opts, :id),
      stream_name: Keyword.get(opts, :stream_name),
      type: type(event),
      data: Map.from_struct(event),
      time: Keyword.get(opts, :time)
    }

    EspEx.Logger.debug(fn ->
      "Event #{inspect(event)} converted to #{inspect(raw_event)}"
    end)

    raw_event
  end

  def to_raw_event(event)
      when is_map(event) do
    opts = raw_event_opts([])
    to_raw_event(event, opts)
  end

  @spec type(event :: struct) :: String.t()
  def type(%{__struct__: module}) do
    module
    |> to_string()
    |> Module.split()
    |> List.last()
  end

  defp raw_event_opts(opts) do
    opts
    |> Keyword.put_new(:id, random_uuid())
    |> Keyword.put_new(:time, naive_datetime_now())
    |> Keyword.put_new(:stream_name, empty_stream_name())
  end

  defp empty_stream_name do
    EspEx.StreamName.empty()
  end

  defp random_uuid do
    Ecto.UUID.generate()
  end

  defp naive_datetime_now do
    DateTime.utc_now()
    |> DateTime.to_naive()
  end
end
