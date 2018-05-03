# Modules

- EspEx.StreamName
  - defstruct [:category, :identifier, :types]
  - new (args):
    - category,
    - optional identifier (nil default),
    - optional types (empty array default)
  - from_string(string) returns %StreamName
  - to_string(%StreamName)
  - has_all_types checks if a list is a sublist of stuct types
  - is_category_stream
  - position_identifier(%StreamName, uint) returns string ("foo-123/1")
- EspEx.EventBus
  - @callback write
  - @callback read_last
  - @callback read_batch
  - @callback read_version
  - EspEx.EventBus.Postgres
    - @behavior EspEx.EventBus
    - write
    - read_last
    - read_batch
    - listen
    - unlisten
    - read_version
- EspEx.Entity
  - @callback new (no args)
- EspEx.Projection
  - @callback apply
  - use macro (creates an `apply` catch-all, adds @behavior EspEx.Projection)
  - apply_all(projection module with @behavior, entity, event list)
- EspEx.RawEvent
  - defstruct [:id, :stream_name, :type, :position, :global_position, :data,
    :metadata, :time]
- EspEx.Event.RawMetadata
  - defstruct [:stream_name, :position, :global_position, :metadata, :time]
- EspEx.Event
  - @callback caused_by(other_event)
  - caused_by(event) sets RawMetadata metadata field following
    [eventide specs](https://github.com/eventide-project/messaging/blob/6027504b4b505a233f74d055321c262a61003803/lib/messaging/message/metadata.rb)
  - use macro that provides macro `defevent`
    - defevent is just defstruct + [:id, :metadata]
- EspEx.EventTransformer
  - @callback transform(string, raw event)
  - use macro (creates generic transform(string, event) and a transform
    catch-all which uses `ExpEx.EventTransformer.transform`,
    @behavior EspEx.EventTransformer)
  - transform(Events module, raw event) returns
    - {:ok, event struct from `Events module`}
    - {:not_found, raw event}
