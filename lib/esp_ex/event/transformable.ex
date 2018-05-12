defprotocol EspEx.Event.Transformable do
  @moduledoc """
  Defines how to convert an event to a RawEvent
  """

  @type raw_event_opts :: [
          id: String.t(),
          stream_name: EspEx.StreamName.t(),
          time: NaiveDateTime.t()
        ]

  @doc """
  Fetch the type that will be used as `:type` for RawEvent
  """
  @spec type(event :: struct) :: String.t()
  def type(event)

  @spec to_raw_event(
          event :: struct,
          opts :: raw_event_opts()
        ) :: EspEx.RawEvent.t()
  def to_raw_event(event, opts)
end

defimpl EspEx.Event.Transformable, for: Any do
  def type(event), do: EspEx.Event.type(event)
  def to_raw_event(event), do: EspEx.Event.to_raw_event(event)
  def to_raw_event(event, opts), do: EspEx.Event.to_raw_event(event, opts)
end