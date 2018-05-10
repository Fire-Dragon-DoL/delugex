defmodule EspEx.RawEvent do
  alias EspEx.RawEvent.Metadata

  @type t :: struct

  @enforce_keys [
    :id,
    :stream_name,
    :type,
    :data,
    :metadata
  ]
  defstruct id: "",
            stream_name: "",
            type: "",
            position: nil,
            global_position: nil,
            data: %{},
            metadata: %Metadata{},
            time: nil
end
