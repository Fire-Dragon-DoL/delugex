defmodule EspEx.RawEvent do
  @type t :: %EspEx.RawEvent{
          event_id: String.t(),
          stream_name: EspEx.StreamName.t(),
          type: String.t(),
          position: non_neg_integer | nil,
          global_position: non_neg_integer | nil,
          data: map(),
          time: NaiveDateTime.t() | nil
        }

  @enforce_keys [
    :event_id,
    :stream_name,
    :type,
    :data
  ]
  defstruct event_id: "",
            stream_name: "",
            type: "",
            position: nil,
            global_position: nil,
            data: %{},
            time: nil
end
