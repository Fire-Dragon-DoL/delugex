defmodule EspEx.Projection do
  alias EspEx.Entity
  alias EspEx.Event
  alias EspEx.Logger

  @callback apply(entity :: Entity.t(), event :: Event.t()) :: Entity.t()

  @spec apply_all(
          current_entity :: Entity.t(),
          module :: atom,
          events :: list(Event.t())
        ) :: Entity.t()
  def apply_all(current_entity, module, events = []) do
    Enum.reduce(events, current_entity, fn event, entity ->
      Logger.debug(fn -> "Applying #{event.type} to #{entity.__struct__}" end)
      module.apply(entity, event)
    end)
  end
end
