# EspEx

Evented system framework

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `esp_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:esp_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/esp_ex](https://hexdocs.pm/esp_ex).

## Index

### Key modules

- [MessageStore.Postgres](#messagestore-postgres) which can write and
  read messages from the database in the specified format. It's used mainly for
  writing, since the reading is performed transparently through `Consumer` and
  `Store`
- [EventTransformer](#eventtransformer) which allows to transform a message as
  it comes from the database into an elixir struct (an **event**) of your
  choice
- [Projection](#projection) which takes a list of events and create the
  specified entity by applying logic for each event
- [StreamName](#streamname) holds the representation of a stream name by
  converting from a raw string `"campaign:command-123"` to a struct following
  the conventions
- [Store](#store) takes a stream and an id, finds all the events on that stream
  and [projects](#projection) the requested entity, returning the final result
- [Consumer.Postgres](#consumer-postgres) listen to any incoming event and
  react by running a handler (a function which pattern matches on that event)
  - [Handler](#handler) a module with a function `handle` which pattern matches
    on the event and does any kind of work (business logic)

### Other relevant modules

- [Entity](#entity) a behaviour that should be implemented by entity modules,
  ensuring those can be initialized without any argument
- [RawEvent](#rawevent) database representation of a _message_ in the
  _messages_ table
  - [RawEvent.Metadata](#rawevent-metadata) represent a set of useful metadata
    attributes that can be stored in a message
- [Event](#event) helpers to create a [RawEvent](#rawevent) from a custom
  struct

## Usage

### `MessageStore.Postgres`

## Licensing

This code is inspired and partially reimplements [eventide](https://eventide-project.org/), as such is also subject to the [eventide LICENSE](eventide-LICENSE)
