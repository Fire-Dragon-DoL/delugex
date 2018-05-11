##### begin behaviour usage code

# TODO some example code (user creation) that uses the transformer
# I'm gonna put it somewhere else later
defmodule EspExTest.User.Events do
  use EspEx.EventTransformer

  defmodule Created do
    defstruct EspEx.EventTransformer.base_event_fields() ++ [:user_id, :email, :name, :birthdate]
  end

  defmodule Updated do
    defstruct EspEx.EventTransformer.base_event_fields() ++ [:user_id, :email, :name, :birthdate]
  end
end

##### end behaviour usage code

defmodule EspExTest.EventTransformerTest do
  use ExUnit.Case, async: true
  doctest EspEx.EventTransformer
  alias EspExTest.User.Events, as: Subject

  def raw_event(type) do
    %EspEx.RawEvent{
      event_id: 123_456,
      stream_name: "user-created-999",
      type: type,
      position: 100,
      global_position: 150,
      data: %{
        user_id: 999,
        email: "johndoe@mail.com",
        name: "John Doe",
        birthdate: "1991-05-01"
      },
      metadata: %{some: :metadata},
      time: "2018-05-01T17:00:55.135053Z"
    }
  end

  def created_event do
    raw_ev = raw_event("created")

    %EspExTest.User.Events.Created{
      event_id: raw_ev.event_id,
      user_id: raw_ev.data.user_id,
      email: raw_ev.data.email,
      name: raw_ev.data.name,
      birthdate: raw_ev.data.birthdate,
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

  def unknown_event do
    raw_ev = raw_event("foo")
    struct(EspEx.UnknownEvent, Map.from_struct(raw_ev))
  end

  def events_module do
    EspExTest.User.Events
  end

  describe "EspEx.EventTransformer.to_event" do
    test "it transforms a raw event into a user defined event (created)" do
      raw_ev = raw_event("created")
      created_ev = created_event()
      assert Subject.to_event(events_module(), raw_ev) == created_ev
    end

    test "it transforms the raw event into an UnknownEvent when the event.type is not known" do
      raw_ev = raw_event("foo")
      unknown_ev = unknown_event()
      assert Subject.to_event(events_module(), raw_ev) == unknown_ev
    end
  end

  describe "EspEx.EventTransformer.to_raw_event" do
    test "it transforms a user defined event into a raw event" do
      raw_ev = raw_event("created")
      created_ev = created_event()
      assert Subject.to_raw_event(created_ev) == raw_ev
    end
  end
end
