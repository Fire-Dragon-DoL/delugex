defmodule EspEx.ProjectionTest do
  use ExUnit.Case, async: true
  alias EspEx.Projection

  defmodule Person do
    defstruct [:name]
  end

  defmodule Nopped do
    defstruct []
  end

  defmodule Renamed do
    defstruct [:name]
  end

  defmodule PersonProjection do
    use EspEx.Projection

    @impl EspEx.Projection
    def apply(%Person{} = person, %Renamed{name: name}) do
      Map.put(person, :name, name)
    end
  end

  describe "Projection.apply" do
    test "defaults to returning passed entity" do
      entity = PersonProjection.apply(%Person{name: "blah"}, %Nopped{})

      assert entity == %Person{name: "blah"}
    end

    test "is used only for non-overridden clauses" do
      entity =
        %Person{name: "blah"}
        |> PersonProjection.apply(%Nopped{})
        |> PersonProjection.apply(%Renamed{name: "jerry"})

      assert entity == %Person{name: "jerry"}
    end
  end
end
