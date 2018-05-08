##### begin behaviour usage code

# TODO some example code (user creation) that uses the transformer
# I'm gonna put it somewhere else later
defmodule EspExTest.User do
  defstruct [:id, :name]
end

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
      stream_name: 'user-created-123',
      type: 'created',
      position: 1,
      global_position: 10,
      data: %{
        user_id: 123,
        email: 'johndoe@mail.com'
      },
      metadata: %{some: :metadata},
      time: DateTime.utc_now()
    }
  end

  def expected_metadata do
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
    ex_metadata = expected_metadata()

    %EspExTest.User.Events.Created{
      id: raw_ev.id,
      raw_metadata: raw_ev,
      metadata: ex_metadata,
      user_id: raw_ev.data.email,
      email: raw_ev.data.email
    }
  end

  # TODO reorganize
  test "to_event" do
    events_module = EspExTest.User
    assert Subject.to_event(events_module, raw_event()) == created_event()
  end

  # TODO reorganize
  test "to_raw_event" do
    events_module = EspExTest.User
    assert Subject.to_raw_event(created_event()) == raw_event()
  end
end
