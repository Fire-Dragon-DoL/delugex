defmodule Ex2.Task do
  defstruct [:name, :created_at]

  def new do
    %Ex2.Task{}
  end

  def created(task, time) do
    Map.put(task, :created_at, time)
  end
end
