defmodule Delugex.MessageStore.Database do
  # Behaviour
  @callback get(session, opts)
  @callback put(session, opts)
end

defmodule Delugex.MessageStore do
  @callback read(stream_name, opts)
  @callback write(stream_name, opts)
  @callback write_initial(stream_name, opts)
  @callback write_reply(previous_message)

  # use Delugex.MessageStore provides functions (with __MODULE__ is used in):
  # - read(stream_name, opts)
  # - write(stream_name, opts)
  # - write_initial(stream_name, opts)
  # - write_reply(previous_message)
  #
  # Adds @behaviour Delugex.MessageStore

  def read(database, stream_name, opts) do
    other_opts = opts ++ [stream_name: stream_name]
    database.get(other_opts)
    # do more stuff
  end
end

defmodule Delugex.MessageStore.Ecto.Postgres.Database do
  @behaviour Delugex.MessageStore.Database

  def get(session, opts) do
    params = extract_stuff_from_opts
    Ecto.Adapters.SQL.query!(session, sql, params)
  end
  # def put
end

defmodule MessageStore.Database do
  use Delugex.MessageStore.Ecto.Postgres.Database, repo: MyRepo
end

defmodule MessageStore do
  use Delugex.MessageStore, database: MessageStore.Database
end

MessageStore.read(stream_name, position: nil, batch_size: 1000)

# Consumer

defmodule Delugex.Consumer do
  # use Delugex.Consumer
  #   use GenServer
  #   consumer logic handling message + polling
end

defmodule Consumer do
  use Delugex.Consumer, database: MessageStore.Database, identifier: "foo"
end
