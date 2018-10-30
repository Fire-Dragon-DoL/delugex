defmodule Delugex.Event do
  @moduledoc """
  Converts a generic event into a RawEvent
  """

  alias Delugex.RawEvent
  alias Delugex.StreamName
  alias Delugex.Event.Transformable, as: Transformer

  def to_raw_event(event) when is_map(event) do
    Transformer.to_raw_event(event)
  end

  @spec to_raw_event(
          event :: struct(),
          raw_event_base :: Delugex.RawEvent.t()
        ) :: Delugex.RawEvent.t()
  def to_raw_event(event, %RawEvent{} = raw_event_base) when is_map(event) do
    Transformer.to_raw_event(event, raw_event_base)
  end

  @spec to_raw_event(
          event :: struct(),
          stream_name :: Delugex.StreamName.t()
        ) :: Delugex.RawEvent.t()
  def to_raw_event(event, %StreamName{} = stream_name) when is_map(event) do
    Transformer.to_raw_event(event, stream_name)
  end

  @spec type(text :: String.t()) :: String.t()
  def type(text) when is_bitstring(text), do: text

  @spec type(event :: struct) :: String.t()
  def type(%{__struct__: module}) do
    module
    |> to_string()
    |> Module.split()
    |> List.last()
  end
end
