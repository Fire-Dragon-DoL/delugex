defmodule Ex1.Task do
  defstruct [:name, :created_at]

  defimpl EspEx.Entity do
    def new do
      %Ex1.Task{}
    end
  end

  def created(task, time) do
    Map.put(task, :created_at, time)
  end
end
