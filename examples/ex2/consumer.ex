defmodule Ex2.Consumer do
  use GenServer

  def start_link(_) do
    EspEx.Consumer.start_link(__MODULE__, identifier: __MODULE__)
  end

  def on(raw_event) do
    event = Ex1.Events.transform(raw_event.type, raw_event)
    handle(event)
  end

  def handle(%Ex2.Events.Created{} = created) do
    # handle the event
    # write some other event
    EspEx.EventBus.write(%Ex2.Events.Started{})
  end

  def handle(_) do
    IO.puts("Event unhandled")
  end
end
