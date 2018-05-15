defmodule Support.EspEx.EventBus.Static do
  use EspEx.EventBus

  alias EspEx.RawEvent
  alias EspEx.StreamName

  @stream_name %StreamName{category: "campaign", identifier: "123", types: []}
  @messages [
    %RawEvent{
      id: "123-456",
      stream_name: @stream_name,
      type: "Updated",
      position: 0,
      global_position: 0,
      data: %{name: "Foo"}
    },
    %RawEvent{
      id: "678-91011",
      stream_name: @stream_name,
      type: "Updated",
      position: 1,
      global_position: 1,
      data: %{name: "Bar"}
    },
    %RawEvent{
      id: "uuid",
      stream_name: @stream_name,
      type: "Updated",
      position: 2,
      global_position: 2,
      data: %{name: "Lol"}
    }
  ]

  @impl EspEx.EventBus
  def write(_, _ \\ nil), do: 3

  @impl EspEx.EventBus
  def read_last(@stream_name), do: List.last(@messages)

  @impl EspEx.EventBus
  def read_last(_), do: nil

  @impl EspEx.EventBus
  def read_batch(@stream_name, position, batch_size) do
    @messages
    |> Enum.drop(position)
    |> Enum.take(batch_size)
  end

  def read_batch(_, _, _), do: []
  def read_batch(stream_name), do: read_batch(stream_name, 0, 10)
  def read_batch(stream_name, pos), do: read_batch(stream_name, pos, 10)

  @impl EspEx.EventBus
  def read_version(@stream_name), do: List.last(@messages).position

  @impl EspEx.EventBus
  def read_version(_), do: nil

  @impl EspEx.EventBus
  def listen(_, _, _ \\ []), do: {:ok, nil}

  @impl EspEx.EventBus
  def unlisten(_, _ \\ []), do: nil
end
