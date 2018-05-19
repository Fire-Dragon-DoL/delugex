defprotocol EspEx.Event.Transformable do
  @moduledoc """
  Defines how to convert an event to a RawEvent
  """

  @fallback_to_any true

  @doc """
  Fetch the type that will be used as `:type` for RawEvent
  """
  def type(event_or_text)

  def to_raw_event(event, raw_event_base)
end

defimpl EspEx.Event.Transformable, for: Any do
  @spec type(event_or_text :: struct | String.t()) :: String.t()
  def type(event_or_text), do: EspEx.Event.type(event_or_text)

  def to_raw_event(event), do: EspEx.Event.to_raw_event(event)

  @spec to_raw_event(
          event :: struct,
          raw_event_base :: EspEx.RawEvent.t()
        ) :: EspEx.RawEvent.t()
  def to_raw_event(event, raw_event_base) do
    EspEx.Event.to_raw_event(event, raw_event_base)
  end
end
