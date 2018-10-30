defmodule Delugex.Event.Unknown do
  @type t :: %Delugex.Event.Unknown{raw_event: Delugex.RawEvent.t()}

  @enforce_keys [:raw_event]
  defstruct [:raw_event]

  defimpl Delugex.Event.Transformable do
    def type(_event), do: "Unknown"
    def to_raw_event(%{raw_event: raw_event}), do: raw_event
    def to_raw_event(%{raw_event: raw_event}, _), do: raw_event
  end
end
