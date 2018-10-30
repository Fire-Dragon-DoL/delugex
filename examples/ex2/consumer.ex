defmodule Ex2.Consumer do
  use GenServer

  def start_link(_) do
    Delugex.Consumer.start_link(__MODULE__, identifier: __MODULE__)
    Delugex.Consumer.listen(__MODULE__)
  end

  def handle_cast(:event_received, raw_event) do
    event = Ex2.Task.Events.transform(raw_event.type, raw_event)
    handle(event)
  end

  def handle(%Ex2.Task.Events.Created{} = created) do
    # handle the event
    # write some other event
    Delugex.EventBus.write(%Ex2.Task.Events.Started{})
  end

  def handle(_) do
    IO.puts("Event unhandled")
  end
end
