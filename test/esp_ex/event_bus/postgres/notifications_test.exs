defmodule EspEx.EventBus.Postgres.NotificationsTest do
  use ExUnit.Case, async: true
  alias EspEx.EventBus.Postgres.Notifications

  setup_all do
    %{channel: "test_channel", data: "some data"}
  end

  test "#listen & #notify", state do
    {:ok, ref} = Notifications.listen(state.channel)
    Notifications.notify(state.channel, state.data)
    channel = state.channel
    data = state.data
    assert_received {:notification, connection_pid, ^ref, ^channel, ^data}
    assert connection_pid == Process.whereis(Postgrex.Notifications)
  end

  test "#unlisten", state do
    {:ok, ref} = Notifications.listen(state.channel)
    Notifications.unlisten(ref, state.channel)
    Notifications.notify(state.channel, state.data)
    channel = state.channel
    data = state.data
    refute_received {:notification, connection_pid, ^ref, ^channel, ^data}
  end
end
