defmodule EspEx.ConsumerTest do
  use ExUnit.Case

  alias EspEx.EventBus.Postgres, as: EventBus
  alias EspEx.StreamName
  alias EspEx.Consumer
  alias EspEx.Event

  defp truncate_messages do
    EspEx.EventBus.Postgres.Repo
    |> Ecto.Adapters.SQL.query!("TRUNCATE TABLE messages", [])
  end

  defmodule Events do
    use EspEx.EventTransformer

    defmodule Renamed do
      defstruct []
    end

    defmodule Spammed do
      defstruct []
    end
  end

  defmodule CampaignConsumer do
    use EspEx.Consumer,
      event_bus: EventBus,
      event_transformer: Events,
      stream_name: %StreamName{category: "campaign", types: []}

    use EspEx.Handler

    @impl EspEx.Handler
    def handle(%Events.Renamed{}, _, pid) do
      send(pid, {:renamed})
    end

    @impl EspEx.Handler
    def handle(%Events.Spammed{}, _, pid) do
      send(pid, {:spammed})
    end
  end

  @stream_name %StreamName{category: "campaign", identifier: "123", types: []}

  describe "Consumer" do
    test "handles renamed events" do
      {:ok, pid} = Consumer.start_link(CampaignConsumer, self())

      %Events.Renamed{}
      |> Event.to_raw_event(stream_name: @stream_name)
      |> EventBus.write!()

      assert_receive {:renamed}, 500

      Consumer.stop(pid)
      truncate_messages()
    end

    test "handles spammed events" do
      {:ok, pid} = Consumer.start_link(CampaignConsumer, self())

      %Events.Spammed{}
      |> Event.to_raw_event(stream_name: @stream_name)
      |> EventBus.write!()

      assert_receive {:spammed}, 500

      Consumer.stop(pid)
      truncate_messages()
    end
  end
end
