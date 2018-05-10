defmodule EspEx.EventTransformer do
  @moduledoc """
  Helps converting from and to a raw event. A raw event is basically a map as
  it comes from the database.

  It's a behavior (fill-in the types for callbacks)

  It can be "used" with `use EspEx.EventTransformer` which would:
  - @behavior EspEx.EventTransformer
  - provide a default `to_event` which catches any event and convert them (use
    the created `EspEx.EventTransformer.to_event`)
  - provide a default `to_raw_event`
  """

  @callback to_event(Module, RawEvent.t()) :: Struct.t
  @callback to_raw_event(Struct.t()) :: RawEvent.t

  # TODO do I really need this?
  # needed in order to call -> use MyModule
  # where does the implementation go?
  # here or somewhere else?
  defmacro __using__(_) do
    # what goes inside here?
    # the implementation?
    # nothing?
  end

  def base_event_fields, do: [:event_id, :raw_metadata]

  @doc ~S"""
  Converts from a RawEvent to an Event, which is a struct defined
  by the user, in a module defined by the user, the only known things is that
  it has the `event_id` field and the `raw_metadata` field.

  Takes a %RawEvent and it creates a new Event, based on events_module plus the
  `:type` field in RawEvent. So it becomes `#{events_module}.#{type}` (check
  for errors, create a custom struct %EspEx.Events.Unknown if it's missing).
  Then copy `event_id` to `event_id`. Then, it grabs all the remaining
  fields in RawEvent excluding `data` and it creates a `RawMetadata` out of it,
  which is stored in `:raw_metadata` field. Finally all fields in `data` are
  copied in the Event (which is a map)
  """
  def to_event(events_module, raw_event) do
    type          = String.capitalize(raw_event.type)
    string_module = to_string(events_module)
    modules       = [string_module, type]
    event_module  = safe_concat(modules)
    data          = raw_event.data

    event = struct(event_module, data) # TODO might cause key collision
    event = Map.put(event, :event_id, raw_event.event_id)
    event = Map.put(event, :raw_metadata, raw_metadata(raw_event))

    event
  end

  @doc """
  Converts from a user defined Event to a RawEvent. It copies `event_id` to
  `event_id`, then everything in `raw_metadata` becomes normal fields in
  RawEvent. Finally, any field remaining in `Event` (after removing :id and
  :raw_metadata) goes into Event `data` field

  Takes a raw event (basically a map of the row coming from the database) and
  converts it to a user-defined struct (so that the user can pattern-match).
  For example:
  %RawEvent{event_id: "123", type: "Created"}
  """
  def to_raw_event(event) do
    nil
  end

  defp safe_concat(modules) do
    try do
      # TODO add more safety
      # Code.ensure_compiled?(event)
      # function_exported?(event, :__struct__, 0)
      Module.safe_concat(modules)
    rescue
      ArgumentError -> nil
    end
  end

  defp raw_metadata(raw_event) do
    struct(%EspEx.RawMetadata{}, Map.from_struct(raw_event))
  end
end
