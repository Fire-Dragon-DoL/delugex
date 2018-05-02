defmodule Ex2.Consumer do
  use GenServer

  def start_link(_) do
    EspEx.Consumer.start_link(__MODULE__, identifier: __MODULE__)
    GenServer.cast(:read_next)
  end

  def handle_cast(:read_next) do
    raw_event = EspEx.Consumer.read_next()
    GenServer.cast(:event_found, raw_event)
  end

  def handle_cast(:event_found, raw_event) do
    event = Ex1.Events.transform(raw_event.type, raw_event)
    handle(event)
    GenServer.cast(:read_next)
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
