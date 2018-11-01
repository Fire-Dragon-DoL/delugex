defprotocol Delugex.Event.Transformable do
  @moduledoc """
  Defines how to convert a term into an Event
  """

  @fallback_to_any true

  @doc """
  Fetch the type that will be used as `:type` for Event.Raw
  """
  def type(term_or_text)

  def to_event(term)
  def to_event(term, event_base)
end

defimpl Delugex.Event.Transformable, for: Any do
  @spec type(term_or_text :: any() | String.t()) :: String.t()
  def type(term_or_text), do: Delugex.Event.type(term_or_text)

  def to_event(term), do: Delugex.Event.Transformer.to_event(term)

  @spec to_event(
          term :: any(),
          event_base :: Delugex.Event.Raw.t()
        ) :: Delugex.Event.Raw.t()
  def to_event(term, %Delugex.Event.Raw{} = event_base) do
    Delugex.Event.Transformer.to_event(term, event_base)
  end

  @spec to_event(
          term :: any(),
          stream_name :: Delugex.StreamName.t()
        ) :: Delugex.Event.Raw.t()
  def to_event(term, %Delugex.StreamName{} = stream_name) do
    Delugex.Event.Transformer.to_event(term, stream_name)
  end
end
