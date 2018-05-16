defmodule EspEx.Consumer do
  @moduledoc """
  Listen to a stream allowing to handle any incoming events
  """

  defstruct listener: nil,
            position: 0,
            events: [],
            meta: nil

  def start(module, meta \\ nil, opts \\ []) do
    module
    |> GenServer.start(meta, opts)
    |> listen()
  end

  def start_link(module, meta \\ nil, opts \\ []) do
    module
    |> GenServer.start_link(meta, opts)
    |> listen()
  end

  def stop(server, reason \\ :normal, timeout \\ :infinity) do
    GenServer.stop(server, reason, timeout)
  end

  defp listen({:ok, pid}) do
    GenServer.call(pid, {:listen})
    {:ok, pid}
  rescue
    RuntimeError ->
      Process.exit(pid, :kill)
      {:error, "Consumer can't start listener"}
  end

  defp listen(result), do: result

  @doc """
  - `:event_bus` **required** an `EspEx.EventBus` implementation
  - `:event_transformer` **required** an `EspEx.EventTransformer`
    implementation
  - `:stream_name` **required** a `EspEx.StreamName`
  - `:identifier` (optional) a `String` identifying uniquely this consumer.
    Defaults to the current module name
  - `:handler` (optional) a `EspEx.Handler` implementation. Defaults to using
    the current module
  - `:listen_opts` (optional) options that will be provided to to the
    `event_bus` that listen call as last argument
  """
  defmacro __using__(opts \\ []) do
    event_bus = Keyword.get(opts, :event_bus)
    event_transformer = Keyword.get(opts, :event_transformer)
    stream_name = Keyword.get(opts, :stream_name)
    identifier = Keyword.get(opts, :identifier, to_string(__MODULE__))
    handler = Keyword.get(opts, :handler, nil)
    listen_opts = Keyword.get(opts, :listen_opts, [])

    quote do
      use GenServer

      @event_bus unquote(event_bus)
      @event_transformer unquote(event_transformer)
      @stream_name unquote(stream_name)
      @identifier unquote(identifier)
      @listen_opts unquote(listen_opts)
      @consumer unquote(__MODULE__)

      defp handler do
        case unquote(handler) do
          nil -> __MODULE__
          _ -> unquote(handler)
        end
      end

      @impl GenServer
      def init(meta), do: {:ok, %@consumer{meta: meta}}

      @impl GenServer
      def handle_call({:listen}, _, %@consumer{listener: nil} = consumer) do
        {:ok, listener} = @event_bus.listen(@stream_name, @listen_opts)

        consumer = Map.put(consumer, :listener, listener)
        {:reply, {:ok, nil}, consumer}
      end

      @impl GenServer
      def handle_call({:listen}, _, %@consumer{} = consumer) do
        {:reply, {:error, "Already listening"}, consumer}
      end

      @impl GenServer
      def handle_info(
            {:notification, _, _, channel, _payload},
            %@consumer{} = consumer
          ) do
        EspEx.Logger.debug(fn ->
          "[##{@identifier}] Notification for stream: #{channel}"
        end)

        request_events()

        {:noreply, consumer}
      end

      @impl GenServer
      def handle_info({:reminder}, %@consumer{} = consumer) do
        EspEx.Logger.debug(fn -> "[##{@identifier}] Reminder" end)

        request_events()

        {:noreply, consumer}
      end

      @impl GenServer
      def handle_cast({:request_events}, %@consumer{} = consumer) do
        fetch_events(consumer)
      end

      @impl GenServer
      def handle_cast({:process_event}, %@consumer{} = consumer) do
        consume_event(consumer)
      end

      @impl GenServer
      def terminate(:normal, consumer), do: unlisten(consumer)
      def terminate(:shutdown, consumer), do: unlisten(consumer)
      def terminate({:shutdown, _}, consumer), do: unlisten(consumer)
      defoverridable terminate: 2

      defp fetch_events(%{events: []} = consumer) do
        events = read_batch(consumer)

        consumer =
          case events do
            [] ->
              consumer

            _ ->
              process_next_event()
              Map.put(consumer, :events, events)
          end

        {:noreply, consumer}
      end

      defp fetch_events(consumer), do: {:noreply, consumer}

      defp consume_event(%{events: []} = consumer) do
        request_events()
        {:noreply, consumer}
      end

      defp consume_event(
             %{
               events: [raw_event | events],
               meta: meta
             } = consumer
           ) do
        handle_event(raw_event, meta)

        consumer =
          consumer
          |> Map.put(:events, events)
          |> Map.put(:position, raw_event.position + 1)

        process_next_event()

        {:noreply, consumer}
      end

      defp handle_event(raw_event, meta) do
        event = @event_transformer.to_event(raw_event)

        handler().handle(event, raw_event, meta)
      end

      defp read_batch(%{position: position}) do
        @event_bus.read_batch(@stream_name, position)
      end

      defp unlisten(%{listener: listener}) do
        @event_bus.unlisten(listener, @listen_opts)
      end

      defp process_next_event do
        GenServer.cast(self(), {:process_event})
      end

      defp request_events do
        GenServer.cast(self(), {:request_events})
      end
    end
  end
end
