defmodule EspExTest do
  use ExUnit.Case
  doctest EspEx

  test "greets the world" do
    assert EspEx.hello() == :world
  end
end
