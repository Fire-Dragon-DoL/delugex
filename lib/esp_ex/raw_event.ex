defmodule EspEx.RawEvent do
  @type t :: struct
  defstruct [:event_id, :metadata, :stream_name, :type, :position, :global_position,
  :data, :time]
end
