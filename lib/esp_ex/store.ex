defmodule EspEx.Store do
  @moduledoc """
  Builds the latest version of an entity based on its stream
  """

  alias EspEx.Logger

  @callback fetch(identifier :: EspEx.StreamName.id()) ::
              {struct(), EspEx.EventBus.version() | nil}

  defmacro __using__(opts \\ []) do
    event_bus = Keyword.get(opts, :event_bus)
    entity_builder = Keyword.get(opts, :entity_builder)
    event_transformer = Keyword.get(opts, :event_transformer)
    projection = Keyword.get(opts, :projection)
    stream_name = Keyword.get(opts, :stream_name)

    quote do
      @behaviour unquote(__MODULE__)

      @impl unquote(__MODULE__)
      def fetch(identifier \\ nil) do
        stream = unquote(stream_name)

        stream =
          case identifier do
            nil -> stream
            _ -> Map.put(stream, :identifier, identifier)
          end

        unquote(__MODULE__).fetch(
          unquote(event_bus),
          unquote(entity_builder),
          unquote(event_transformer),
          unquote(projection),
          stream
        )
      end
    end
  end

  @spec fetch(
          event_bus :: module,
          entity_builder :: module,
          event_transformer :: module,
          projection :: module,
          stream_name :: EspEx.StreamName.t()
        ) :: {struct(), EspEx.EventBus.version() | nil}
  def fetch(
        event_bus,
        entity_builder,
        event_transformer,
        projection,
        %EspEx.StreamName{} = stream_name
      )
      when is_atom(event_bus) and is_atom(entity_builder) and is_atom(event_transformer) and
             is_atom(projection) do
    new_ent = entity_builder.new()

    event_bus.stream(stream_name)
    |> Stream.map(event_and_position(event_transformer))
    |> Enum.reduce({new_ent, nil}, fn {event, position}, {entity, _} ->
      Logger.debug(fn ->
        "Applying #{event.__struct__} to #{entity.__struct__} [##{position}]"
      end)

      entity = projection.apply(entity, event)
      {entity, position}
    end)
    |> maybe_mark_empty
  end

  defp maybe_mark_empty({_, nil}), do: {nil, nil}
  defp maybe_mark_empty({_, _} = result), do: result

  defp event_and_position(event_transformer) do
    fn raw_event ->
      {event_transformer.to_event(raw_event), raw_event.position}
    end
  end
end
