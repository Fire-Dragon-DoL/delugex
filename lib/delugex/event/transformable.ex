defprotocol Delugex.Event.Transformable do
  @moduledoc """
  Defines how to convert an event to a RawEvent
  """

  @fallback_to_any true

  @doc """
  Fetch the type that will be used as `:type` for RawEvent
  """
  def type(event_or_text)

  def to_raw_event(event)
  def to_raw_event(event, raw_event_base)
end

defimpl Delugex.Event.Transformable, for: Any do
  @spec type(event_or_text :: struct | String.t()) :: String.t()
  def type(event_or_text), do: Delugex.Event.type(event_or_text)

  def to_raw_event(event), do: Delugex.Event.Transformer.to_raw_event(event)

  @spec to_raw_event(
          event :: struct,
          raw_event_base :: Delugex.RawEvent.t()
        ) :: Delugex.RawEvent.t()
  def to_raw_event(event, %Delugex.RawEvent{} = raw_event_base) do
    Delugex.Event.Transformer.to_raw_event(event, raw_event_base)
  end

  @spec to_raw_event(
          event :: struct,
          stream_name :: Delugex.StreamName.t()
        ) :: Delugex.RawEvent.t()
  def to_raw_event(event, %Delugex.StreamName{} = stream_name) do
    Delugex.Event.Transformer.to_raw_event(event, stream_name)
  end
end
