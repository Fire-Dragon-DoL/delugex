defprotocol Delugex.MessageStore.Ecto.Postgres.Session do
  @fallback_to_any true
  def get(session)
end

defimpl Delugex.MessageStore.Ecto.Postgres.Session, for: Any do
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
    repo = Delugex.MessageStore.Ecto.Postgres.Session.get(session)
    params = extract_stuff_from_opts
    Ecto.Adapters.SQL.query!(session, sql, params)
  end
  # def put

  # use Delugex.MessageStore.Ecto.Postgres.Database, repo: MyRepo
  #   get(opts)
end

defmodule Delugex.MessageStore.Ecto.Postgres do
  use Delugex.MessageStore,
    database: Delugex.MessageStore.Ecto.Postgres.Database

  # use Delugex.MessageStore.Ecto.Postgres, repo: MyRepo
  # - read(stream_name, opts)
  # - write(stream_name, opts)
  # - write_initial(stream_name, opts)
  # - write_reply(previous_message)
end

defmodule MessageStore.Ecto.Postgres do
  use Delugex.MessageStore.Ecto.Postgres, repo: MyRepo
end

defmodule MessageStore.Ecto.Postgres.Database do
  use Delugex.MessageStore.Ecto.Postgres.Database, repo: MyRepo
end

alias MessageStore.Ecto.Postgres, as: MessageStore
alias MessageStore.Ecto.Postgres.Database
MessageStore.read(stream_name, position: nil, batch_size: 1000)
Database.get(opts)

# Consumer

defmodule Delugex.Consumer do
  # use Delugex.Consumer, database: DATABASE_HERE, identifier: OPTIONAL
  #   use GenServer
  #   consumer logic handling message + polling
  #   init accepts session argument (will be Repo), stream_name, condition
end

defmodule Delugex.Consumer.Ecto.Postgres do
  # use Delugex.Consumer.Ecto.Postgres, repo: MyRepo, identifier: OPTIONAL
  #   use Delugex.Consumer,
  #     identifier: OPTIONAL,
  #     database: Delugex.MessageStore.Ecto.Postgres.Database
  #   init accepts stream_name, condition
end

defmodule Consumer do
  use Delugex.Consumer.Ecto.Postgres, identifier: "foo", repo: MyRepo
end

Consumer.start_link(stream_name, condition: condition)

# TODO: Transform to/from json, defevent, MessageData.Read, MessageData.Write
