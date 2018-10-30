defmodule Delugex.Handler.Unhandled do
  @moduledoc false

  defmacro __before_compile__(_env) do
    quote location: :keep do
      @impl Delugex.Handler
      def handle(event, _, _) do
        Delugex.Logger.info(fn -> "Event #{inspect(event)} unhandled" end)
      end
    end
  end
end
