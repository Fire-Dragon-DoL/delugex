defmodule EspEx.RawEvent do
  @moduledoc """
  Representation of an event in memory
  """

  @typedoc """
  - `:data` must be a map, not a struct
  """
  @type t :: %EspEx.RawEvent{
          id: String.t(),
          stream_name: EspEx.StreamName.t(),
          type: String.t(),
          position: non_neg_integer | nil,
          global_position: non_neg_integer | nil,
          data: map(),
          metadata: EspEx.RawEvent.Metadata.t(),
          time: NaiveDateTime.t() | nil
        }

  defstruct id: nil,
            stream_name: nil,
            type: nil,
            position: nil,
            global_position: nil,
            data: %{},
            metadata: %EspEx.RawEvent.Metadata{},
            time: nil

  def caused_by(%__MODULE__{} = event, %__MODULE__{} = other_event) do
    meta = event.metadata

    other_meta =
      other_event.metadata
      |> Map.put(:correlation_stream_name, meta.correlation_stream_name)
      |> Map.put(:reply_stream_name, meta.reply_stream_name)
      |> Map.put(:causation_message_stream_name, event.stream_name)
      |> Map.put(:causation_message_position, event.position)
      |> Map.put(:causation_message_global_position, event.global_position)

    Map.put(other_event, :metadata, other_meta)
  end

  def next_position(position) when is_integer(position), do: position + 1

  def next_global_position(global_position) when is_integer(global_position) do
    global_position + 1
  end
end
