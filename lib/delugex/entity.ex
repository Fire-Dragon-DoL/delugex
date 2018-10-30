defmodule Delugex.Entity do
  @type t :: struct

  @callback new() :: t
end
