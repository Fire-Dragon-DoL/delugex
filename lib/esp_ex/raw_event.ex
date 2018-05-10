defmodule EspEx.RawEvent do
  defstruct [:event_id, :metadata, :stream_name, :type, :position, :global_position,
  :data, :time]
end
