defmodule EspEx.Projection.Unhandled do
  defmacro __before_compile__(_env) do
    quote do
      @impl EspEx.Projection
      def apply(entity, event) do
        EspEx.Logger.warn(fn ->
          "Event #{inspect(event)} ignored for entity #{inspect(entity)}"
        end)

        entity
      end
    end
  end
end
