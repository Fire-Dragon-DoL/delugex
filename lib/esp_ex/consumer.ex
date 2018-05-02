defmodule EspEx.Consumer do
  def start_link(stream_name, %{adapter: nil})
      when is_bitstring(stream_name) do
  end
end
