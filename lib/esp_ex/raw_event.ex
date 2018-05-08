defmodule EspEx.RawEvent do
  defstruct [:id, :metadata, :stream_name, :type, :position, :global_position,
  :data, :time]
end
