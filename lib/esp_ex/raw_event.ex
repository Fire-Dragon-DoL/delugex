defmodule EspEx.RawEvent do
  defstruct [:id, :stream_name, :type, :position, :global_position, :data,
  :metadata, :time]
end
