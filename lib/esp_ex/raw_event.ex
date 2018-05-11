defmodule EspEx.RawEvent do
  alias EspEx.RawEvent.Metadata

  @type t :: %RawEvent{
          id: String.t(),
          stream_name: EspEx.StreamName.t(),
          type: String.t(),
          position: non_neg_integer | nil,
          global_position: non_neg_integer | nil,
          data: map(),
          metadata: EspEx.RawEvent.Metadata.t(),
          time: NaiveDateTime.t() | nil
        }

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
