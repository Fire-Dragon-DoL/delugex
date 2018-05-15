defmodule EspEx.RawEvent do
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

  @typedoc """
  - `:data` must be a map, not a struct
  """
  @enforce_keys [
    :id,
    :stream_name,
    :type,
    :data
  ]
  defstruct id: "",
            stream_name: EspEx.StreamName.empty(),
            type: "",
            position: nil,
            global_position: nil,
            data: %{},
            metadata: %EspEx.RawEvent.Metadata{},
            time: nil
end
