Postgrex.Types.define(
  EspEx.EventBus.Postgres.Types,
  [] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
