defmodule Delugex.Event.Transformer do
  @moduledoc false

  alias Delugex.Event
  alias Delugex.StreamName

  def to_event(term) when is_map(term) do
    to_event(term, %Event{})
  end

  @spec to_event(
          term :: struct(),
          event_base :: Delugex.Event.t()
        ) :: Delugex.Event.t()
  def to_event(term, %Event{} = event_base) when is_map(term) do
    id = event_base.id || random_uuid()
    stream_name = event_base.stream_name
    type = event_base.type || Delugex.Event.type(term)

    raw =
      event_base
      |> Map.put(:id, id)
      |> Map.put(:stream_name, stream_name)
      |> Map.put(:type, type)
      |> Map.put(:data, Map.from_struct(term))

    Delugex.Logger.debug(fn ->
      "Event #{inspect(term)} converted to #{inspect(raw)}"
    end)

    raw
  end

  @spec to_event(
          term :: struct(),
          stream_name :: Delugex.StreamName.t()
        ) :: Delugex.Event.t()
  def to_event(term, %StreamName{} = stream_name) when is_map(term) do
    event_base = %Event{stream_name: stream_name}

    to_event(term, event_base)
  end

  defp random_uuid do
    UUID.uuid4()
  end
end
