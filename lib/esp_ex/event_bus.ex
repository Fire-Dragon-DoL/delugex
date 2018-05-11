defmodule EspEx.EventBus do
  @moduledoc """
  This module provides an interface for specialized event buses. In addition,
  it provides a utility macro that auto-implements write_initial for you based
  on `write` implementation (expects that no messages are present on stream)
  """

  alias EspEx.EventBus.Stream.Position

  @callback write(
              raw_event :: EspEx.RawEvent.t(),
              expected_version :: non_neg_integer | nil
            ) :: non_neg_integer
  @callback write_initial(raw_event :: EspEx.RawEvent.t()) :: non_neg_integer
  @callback read_last(stream_name :: EspEx.StreamName.t()) :: EspEx.RawEvent.t() | nil
  @callback read_batch(
              stream_name :: EspEx.StreamName.t(),
              position :: non_neg_integer,
              batch_size :: pos_integer
            ) :: list(EspEx.RawEvent.t())
  @callback read_version(stream_name :: EspEx.StreamName.t()) :: non_neg_integer | nil
  @callback stream(
              stream_name :: EspEx.StreamName.t(),
              position :: non_neg_integer,
              batch_size :: pos_integer
            ) :: Enumerable.t()

  @spec write_initial(
          event_bus :: module,
          raw_event :: EspEx.RawEvent.t()
        ) :: boolean
  def write_initial(event_bus, raw_event) do
    event_bus.write(raw_event, 0)
    true
  end

  @spec stream(
          event_bus :: module,
          stream_name :: EspEx.StreamName.t(),
          position :: non_neg_integer,
          batch_size :: pos_integer
        ) :: Enumerable.t()
  def stream(event_bus, stream_name, position \\ 0, batch_size \\ 10) do
    stream_position = Position.new(event_bus, stream_name, position, batch_size)
    EspEx.EventBus.Stream.from_position(stream_position)
  end

  defmacro __using__(_) do
    quote do
      @behaviour EspEx.EventBus

      @impl EspEx.EventBus
      def write_initial(raw_event) do
        EspEx.EventBus.write_initial(__MODULE__, raw_event)
      end

      @impl EspEx.EventBus
      def stream(stream_name, position \\ 0, batch_size \\ 10) do
        EspEx.EventBus.stream(__MODULE__, stream_name, position, batch_size)
      end

      defoverridable write_initial: 1, stream: 3
    end
  end
end
