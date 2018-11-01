use Mix.Config

config :logger,
  backends: [],
  utc_log: true,
  compile_time_purge_level: :debug

config :delugex, Delugex.MessageStore.Postgres.Repo,
  pool: Ecto.Adapters.SQL.Sandbox
