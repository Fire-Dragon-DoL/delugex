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
          opts :: raw_event_opts()
        ) :: EspEx.RawEvent.t()
  def to_raw_event(event, opts)
      when is_map(event) and is_list(opts) do
    %RawEvent{
      id: Keyword.get(opts, :id),
      stream_name: Keyword.get(opts, :stream_name),
      type: type(event),
      data: Map.from_struct(event),
      time: Keyword.get(opts, :time)
    }
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
    |> Keyword.put_new(:id, Ecto.UUID.generate())
    |> Keyword.put_new(:time, naive_datetime_now())
    |> Keyword.put_new(:stream_name, EspEx.StreamName.empty())
  end

  defp naive_datetime_now do
    DateTime.utc_now()
    |> DateTime.to_naive()
  end
end
