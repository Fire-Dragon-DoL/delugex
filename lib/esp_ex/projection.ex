defmodule EspEx.Projection do
  alias EspEx.Entity
  alias EspEx.Event
  alias EspEx.Logger

  @callback apply(entity :: Entity.t(), event :: Event.t()) :: Entity.t()

  defmacro __using__(_) do
    quote do
      @behaviour EspEx.Projection

      @impl EspEx.Projection
      def apply(entity, event) do
        EspEx.Logger.warn(fn ->
          struct = entity.__struct__
          type = event.type
          data = inspect(event)
          "Event #{type} ignored for entity #{struct}: #{data}"
        end)

        entity
      end

      defoverridable apply: 2
    end
  end

  @spec apply_all(
          current_entity :: Entity.t(),
          projection_module :: atom,
          events :: list(Event.t())
        ) :: Entity.t()
  def apply_all(current_entity, projection_module, events = []) do
    Enum.reduce(events, current_entity, fn event, entity ->
      Logger.debug(fn -> "Applying #{event.type} to #{entity.__struct__}" end)
      projection_module.apply(entity, event)
    end)
  end
end
