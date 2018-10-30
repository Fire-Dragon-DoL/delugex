defmodule Ex1.Consumer do
  use Delugex.Handler, handle_unhandled: true

  use Delugex.Consumer,
    category: "task",
    identifier: __MODULE__,
    handler: __MODULE__,
    event_transformer: Ex1.Events

  def handle(%Ex1.Task.Events.Created{} = created) do
    # handle the event
    # write some other event
    Delugex.EventBus.write(%Ex1.Events.Task.Started{})
  end
end
