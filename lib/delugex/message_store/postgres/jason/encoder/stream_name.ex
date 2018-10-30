defimpl Jason.Encoder, for: Delugex.StreamName do
  def encode(value, opts) do
    value
    |> to_string()
    |> Jason.Encode.map(opts)
  end
end
