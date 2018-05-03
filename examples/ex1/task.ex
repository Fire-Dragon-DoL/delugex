defmodule Ex1.Task do
  defstruct [:name, :created_at]

  def new() do
    %Ex1.Task{name: ""}
  end

  def created(task, time) do
    Map.put(task, :created_at, time)
  end
end
