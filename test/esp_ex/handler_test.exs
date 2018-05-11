defmodule EspEx.HandlerTest do
  use ExUnit.Case, async: true

  alias EspEx.RawEvent
  alias EspEx.RawEvent.Metadata
  alias EspEx.StreamName

  @stream_name %StreamName{category: "campaign", identifier: "123", types: []}
  @raw_event %RawEvent{
    id: "11111111",
    stream_name: @stream_name,
    type: "Updated",
    data: %{name: "Unnamed"},
    metadata: %Metadata{}
  }

  defmodule Person do
    defstruct []
  end

  defmodule Nopped do
    defstruct []
  end

  defmodule Renamed do
    defstruct []
  end

  defmodule PersonHandler do
    use EspEx.Handler

    @impl EspEx.Handler
    def handle(%Person{}, %Renamed{}, _) do
      send(self(), {:renamed})
    end
  end

  describe "Handler.handle" do
    test "defaults to doing nothing" do
      PersonHandler.handle(%Person{}, %Nopped{}, @raw_event)
    end

    test "calls specific handle when implemented" do
      PersonHandler.handle(%Person{}, %Renamed{}, @raw_event)

      assert_receive({:renamed})
    end
  end
end
