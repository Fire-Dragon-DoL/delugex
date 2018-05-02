defmodule Ex1.Handler do
  use EspEx.Handler, handle_unhandled: true

  def handle(%Ex1.Events.Created{} = created) do
    # handle the event
    # write some other event
  end
end
