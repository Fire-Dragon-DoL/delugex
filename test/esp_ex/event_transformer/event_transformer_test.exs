##### begin behaviour usage code

# TODO some example code (user creation) that uses the transformer
# I'm gonna put it somewhere else later
defmodule EspExTest.User.Events do
  use EspEx.EventTransformer

  defmodule Created do
    defstruct EspEx.EventTransformer.base_event_fields ++ [:user_id, :email]
  end

  defmodule Updated do
    defstruct EspEx.EventTransformer.base_event_fields ++ [:user_id, :email]
  end
end

##### end behaviour usage code

defmodule EspExTest.EventTransformerTest do
  use ExUnit.Case, async: true
  doctest EspEx.EventTransformer
  alias EspExTest.User.Events, as: Subject

  def raw_event do
    %EspEx.RawEvent{
      event_id: 123_456,
      stream_name: "user-created-999",
      type: "created",
      position: 100,
      global_position: 150,
      data: %{
        user_id: 999,
        email: "johndoe@mail.com"
      },
      metadata: %{some: :metadata},
      time: "2018-05-01T17:00:55.135053Z"
    }
  end

  def created_event do
    raw_ev = raw_event()

    %EspExTest.User.Events.Created{
      event_id: raw_ev.event_id,
      user_id: raw_ev.data.user_id,
      email: raw_ev.data.email,
      raw_event: %EspEx.RawEvent{
        event_id: raw_ev.event_id,
        stream_name: raw_ev.stream_name,
        type: raw_ev.type,
        position: raw_ev.position,
        global_position: raw_ev.global_position,
        metadata: raw_ev.metadata,
        time: raw_ev.time
      }
    }
  end

  test "to_event" do
    raw_ev = raw_event()
    created_ev = created_event()
    events_module = EspExTest.User.Events

    assert Subject.to_event(events_module, raw_ev) == created_ev
  end

  test "to_raw_event" do
    raw_ev = raw_event()
    created_ev = created_event()

    assert Subject.to_raw_event(created_ev) == raw_ev
  end
end
