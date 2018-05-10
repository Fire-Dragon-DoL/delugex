defmodule EspEx.HandlerTest do
  use ExUnit.Case, async: true
  alias EspEx.RawEvent

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
      PersonHandler.handle(%Person{}, %Nopped{}, %RawEvent{})
    end

    test "calls specific handle when implemented" do
      PersonHandler.handle(%Person{}, %Renamed{}, %RawEvent{})

      assert_receive({:renamed})
    end
  end
end
