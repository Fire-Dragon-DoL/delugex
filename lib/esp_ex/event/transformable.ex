defprotocol EspEx.Event.Transformable do
  @moduledoc """
  Defines how to convert an event to a RawEvent
  """

  @fallback_to_any true

  @doc """
  Fetch the type that will be used as `:type` for RawEvent
  """
  def type(event)

  def to_raw_event(event, opts)
end

defimpl EspEx.Event.Transformable, for: Any do
  @spec type(event :: struct) :: String.t()
  def type(event), do: EspEx.Event.type(event)

  def to_raw_event(event), do: EspEx.Event.to_raw_event(event)

  @spec to_raw_event(
          event :: struct,
          opts :: EspEx.Event.raw_event_opts()
        ) :: EspEx.RawEvent.t()
  def to_raw_event(event, opts), do: EspEx.Event.to_raw_event(event, opts)
end
