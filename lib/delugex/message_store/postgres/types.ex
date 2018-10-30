Postgrex.Types.define(
  Delugex.MessageStore.Postgres.Types,
  [] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
