defmodule Ex1.Consumer do
  use EspEx.Consumer,
    identifier: __MODULE__,
    handler: Ex1.Handler,
    event_transformer: Ex1.EventTransformer
end
