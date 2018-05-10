defmodule EspEx.Handler.Unhandled do
  @moduledoc false

  defmacro __before_compile__(_env) do
    quote do
      @impl EspEx.Handler
      def handle(entity, event, _) do
        EspEx.Logger.info(fn ->
          "Event #{inspect(event)} unhandled for entity #{inspect(entity)}"
        end)
      end
    end
  end
end
