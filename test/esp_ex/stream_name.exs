defmodule EspEx.StreamNameTest do
  use ExUnit.Case, async: true
  doctest EspEx.StreamName
  alias EspEx.StreamName

  import EspEx.StreamName,
    only: [
      new: 3,
      new: 2,
      new: 1,
      from_string: 1,
      to_string: 1
    ]

  describe "StreamName.from_string" do
    test "campaign:command+position-123" do
      text = from_string("campaign:command+position-123")
      map = new("campaign", "123", ["command", "position"])

      assert text == map
    end

    test "campaign:position+command-123" do
      text = from_string("campaign:position+command-123")
      map = new("campaign", "123", ["command", "position"])

      assert text == map
    end

    test "campaign:position-123" do
      text = from_string("campaign:position-123")
      map = new("campaign", "123", ["position"])

      assert text == map
    end

    test "campaign:position" do
      text = from_string("campaign:position")
      map = new("campaign", nil, ["position"])

      assert text == map
    end

    test "campaign:position+command" do
      text = from_string("campaign:position+command")
      map = new("campaign", nil, ["command", "position"])

      assert text == map
    end

    test "campaign:-" do
      text = from_string("campaign:-")
      map = new("campaign", nil, [])

      assert text == map
    end

    test "campaign:" do
      text = from_string("campaign:")
      map = new("campaign", nil, [])

      assert text == map
    end

    test "campaign-" do
      text = from_string("campaign-")
      map = new("campaign", nil, [])

      assert text == map
    end

    test "campaign+" do
      text = from_string("campaign+")
      map = new("campaign+", nil, [])

      assert text == map
    end

    test "campaign" do
      text = from_string("campaign")
      map = new("campaign", nil, [])

      assert text == map
    end

    test "+" do
      text = from_string("+")
      map = new("+", nil, [])

      assert text == map
    end

    test "campaign---" do
      text = from_string("campaign---")
      map = new("campaign", "--", [])

      assert text == map
    end

    test "campaign:command-123+asd:23" do
      text = from_string("campaign:command-123+asd:23")
      map = new("campaign", "123+asd:23", ["command"])

      assert text == map
    end

    test "campaign:command+" do
      text = from_string("campaign:command+")
      map = new("campaign", nil, ["command"])

      assert text == map
    end

    test "campaign-123" do
      text = from_string("campaign-123")
      map = new("campaign", "123", [])

      assert text == map
    end

    test "campaign-123-asd-456" do
      text = from_string("campaign-123-asd-456")
      map = new("campaign", "123-asd-456", [])

      assert text == map
    end

    test "raises with empty string" do
      assert_raise ArgumentError, fn ->
        from_string("")
      end
    end

    test "raises with a blank string" do
      assert_raise ArgumentError, fn ->
        from_string("           ")
      end
    end

    test "raises with a blank string" do
      assert_raise ArgumentError, fn ->
        from_string("           ")
      end
    end

    test "raises with just : since it's blank" do
      assert_raise ArgumentError, fn ->
        from_string("   :  ")
      end
    end

    test "raises with just - since it's blank" do
      assert_raise ArgumentError, fn ->
        from_string("   -  ")
      end
    end

    test "raises with just :- since it's blank" do
      assert_raise ArgumentError, fn ->
        from_string("   :-  ")
      end
    end

    test "raises with just :- even without spaces around" do
      assert_raise ArgumentError, fn ->
        from_string(":-")
      end
    end
  end

  describe "StreamName.new" do
    test "raises when category is blank" do
      assert_raise ArgumentError, fn ->
        new("       ")
      end
    end

    test "raises when category is not a string" do
      assert_raise FunctionClauseError, fn ->
        new(123)
      end
    end

    test "raises when category is nil" do
      assert_raise FunctionClauseError, fn ->
        new(nil)
      end
    end

    test "raises when category contains invalid characters" do
      assert_raise ArgumentError, fn ->
        new("    asd:-sfd  ")
      end
    end

    test "raises when identifier is not nil or string" do
      assert_raise FunctionClauseError, fn ->
        new("campaign", %{something: 123})
      end
    end

    test "raises when types is not a list" do
      assert_raise FunctionClauseError, fn ->
        new("campaign", "asd-123", %{wrong: 123})
      end
    end
  end

  describe "StreamName.to_string" do
    test "has types always in the same order" do
      map = new("campaign", "123", ["position", "command"])
      text = "campaign:command+position-123"

      assert to_string(map) == text
    end
  end
end
