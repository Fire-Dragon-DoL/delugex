defimpl Jason.Encoder, for: Delugex.RawEvent.Metadata do
  def encode(value, opts) do
    value
    |> Map.from_struct()
    |> Jason.Encode.map(opts)
  end
end
