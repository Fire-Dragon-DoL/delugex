defmodule EspEx.Consumer do
  defstruct listener: nil,
            position: 0,
            events: [],
            read_more: true,
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

        start_read_events()

        {:noreply, consumer}
      end

      @impl GenServer
      def handle_info({:reminder}, %@consumer{} = consumer) do
        EspEx.Logger.debug(fn -> "[##{@identifier}] Reminder" end)

        start_read_events()

        {:noreply, consumer}
      end

      @impl GenServer
      def handle_cast({:read_events}, %@consumer{} = consumer) do
        read_events(consumer)
      end

      @impl GenServer
      def handle_cast({:next_event}, %@consumer{} = consumer) do
        next_event(consumer)
      end

      @impl GenServer
      def terminate(:normal, consumer), do: unlisten(consumer)
      def terminate(:shutdown, consumer), do: unlisten(consumer)
      def terminate({:shutdown, _}, consumer), do: unlisten(consumer)
      defoverridable terminate: 2

      defp read_events(%{events: [], read_more: false} = consumer) do
        {:noreply, consumer}
      end

      defp read_events(%{events: [], read_more: true} = consumer) do
        events = read_batch(consumer)

        consumer =
          case events do
            [] ->
              Map.put(consumer, :read_more, false)

            _ ->
              process_next_event()

              consumer
              |> Map.put(:events, events)
              |> Map.put(:read_more, true)
          end

        {:noreply, consumer}
      end

      defp read_events(consumer), do: {:noreply, consumer}

      defp next_event(%{events: []} = consumer) do
        start_read_events()
        {:noreply, consumer}
      end

      defp next_event(
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
        GenServer.cast(self(), {:next_event})
      end

      defp start_read_events do
        GenServer.cast(self(), {:read_events})
      end
    end
  end
end
