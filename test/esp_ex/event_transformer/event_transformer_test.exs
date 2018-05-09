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
  alias EspEx.EventTransformer, as: Subject

  def raw_event do
    %EspEx.RawEvent{
      id: 123_456,
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

  def raw_metadata do
    raw_ev = raw_event()

    %EspEx.RawMetadata{
      stream_name: raw_ev.stream_name,
      position: raw_ev.position,
      global_position: raw_ev.global_position,
      metadata: raw_ev.metadata,
      time: raw_ev.time
    }
  end

  def created_event do
    raw_ev = raw_event()
    raw_metadata = raw_metadata()

    %EspExTest.User.Events.Created{
      id: raw_ev.id,
      raw_metadata: raw_metadata,
      user_id: raw_ev.data.email,
      email: raw_ev.data.email
    }
  end

  # TODO reorganize
  test "to_event" do
    event = raw_event()
    expected_event = created_event()

    events_module = EspExTest.User.Events
    assert Subject.to_event(events_module, event) == expected_event
  end

  # TODO reorganize
  test "to_raw_event" do
    events_module = EspExTest.User.Events
    expected_event = raw_event()
    event = created_event()
    assert Subject.to_raw_event(event) == expected_event
  end
end
