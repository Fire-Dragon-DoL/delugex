use Mix.Config

config :delugex, Delugex.MessageStore.Postgres.Repo,
  pool_size: 15,
  url: System.get_env("DELUGEX_DATABASE_URL")
