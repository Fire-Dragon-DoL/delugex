defprotocol Delugex.MessageStore.Session do
  @fallback_to_any true
  def get(session)
end

defimpl Delugex.MessageStore.Session, for: Any do
  def get(session), do: session
end

defmodule Delugex.MessageStore.Database do
  # Behaviour
  @callback get(session, opts)
  @callback put(session, opts)
end

defmodule Delugex.MessageStore do
  @callback read(session, stream_name, opts)
  @callback write(session, stream_name, opts)
  @callback write_initial(session, stream_name, opts)
  @callback write_reply(session, previous_message, opts)

  # use Delugex.MessageStore provides functions (with __MODULE__ is used in):
  # - read(session, stream_name, opts)
  # - write(session, stream_name, opts)
  # - write_initial(session, stream_name, opts)
  # - write_reply(session, previous_message)
  #
  # Adds @behaviour Delugex.MessageStore

  def read(session, database, stream_name, opts) do
    other_opts = opts ++ [stream_name: stream_name]
    database.get(session, other_opts)
    # do more stuff
  end
end

defmodule Delugex.MessageStore.Ecto.Postgres.Database do
  def get(session, opts) do
    repo = Delugex.MessageStore.Session.get(session)
    params = extract_stuff_from_opts
    Ecto.Adapters.SQL.query!(session, sql, params)
  end
  # def put
end

defmodule MessageStore.Ecto.Postgres do
  use Delugex.MessageStore,
    database: Delugex.MessageStore.Ecto.Postgres.Database
end

alias MessageStore.Ecto.Postgres, as: MessageStore
MessageStore.read(MyRepo, stream_name, position: nil, batch_size: 1000)
MessageStore.Database.get(MyRepo, opts)

# Consumer

defmodule Delugex.Consumer do
  # use Delugex.Consumer, database: DATABASE_HERE, identifier: OPTIONAL
  #   use GenServer
  #   consumer logic handling message + polling
  #   init accepts session argument (will be Repo), stream_name, condition
end

defmodule Consumer do
  use Delugex.Consumer, database: MessageStore.Database, identifier: "foo"
end

Consumer.start_link(MyRepo, stream_name, condition: condition)

# TODO: Transform to/from json, defevent, MessageData.Read, MessageData.Write
