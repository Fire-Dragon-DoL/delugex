defmodule Support.EspEx.EventBus.Static do
  use EspEx.EventBus

  alias EspEx.RawEvent
  alias EspEx.RawEvent.Metadata
  alias EspEx.StreamName

  @stream_name %StreamName{category: "campaign", identifier: "123", types: []}
  @messages [
    %RawEvent{
      id: "123-456",
      stream_name: @stream_name,
      type: "Updated",
      position: 0,
      global_position: 0,
      data: %{name: "Foo"},
      metadata: %Metadata{}
    },
    %RawEvent{
      id: "678-91011",
      stream_name: @stream_name,
      type: "Updated",
      position: 1,
      global_position: 1,
      data: %{name: "Bar"},
      metadata: %Metadata{}
    },
    %RawEvent{
      id: "uuid",
      stream_name: @stream_name,
      type: "Updated",
      position: 2,
      global_position: 2,
      data: %{name: "Lol"},
      metadata: %Metadata{}
    }
  ]

  @impl EspEx.EventBus
  def write(_, _ \\ nil), do: 3

  @impl EspEx.EventBus
  def read_last(@stream_name), do: List.last(@messages)

  @impl EspEx.EventBus
  def read_last(_), do: nil

  @impl EspEx.EventBus
  def read_batch(@stream_name, position \\ 0, batch_size \\ 10) do
    @messages
    |> Enum.drop(position)
    |> Enum.take(batch_size)
  end

  @impl EspEx.EventBus
  def read_version(@stream_name), do: List.last(@messages).position

  @impl EspEx.EventBus
  def read_version(_), do: nil
end
