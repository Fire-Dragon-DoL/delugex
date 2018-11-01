# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  backends: [:console],
  utc_log: true,
  compile_time_purge_level: :debug

config :delugex, Delugex.MessageStore.Postgres.Repo, pool_size: 15

config :delugex, Delugex.MessageStore.Postgres,
  stream_name: [decoder: Delugex.Stream.Name]

import_config "./environment/#{Mix.env()}.exs"

if File.exists?(Path.expand("./environment/#{Mix.env()}.secret.exs", __DIR__)) do
  import_config "./environment/#{Mix.env()}.secret.exs"
end
