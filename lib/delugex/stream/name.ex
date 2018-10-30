defmodule Delugex.Stream.Name do
  alias __MODULE__

  @moduledoc """
  Stream.Name is a module to manage the location where events are written.
  Stream names could be intended as URLs for where events are located.
  The struct provides an easy way to access the data that
  otherwise would be in a String.
  Stream names are **camelCased**.
  A full stream name might look like: `user:command+position-123`.

  - `user` is the stream name **category**
  - category is required
  - `command` and `position` are the stream **types**
  - `123` is the stream `id` (string, will be UUID)
  - id is optional
  - If the stream name has no `id`, the dash must be omitted
  - Any dash after the first dash are considered part of the id
  - If the stream has no types, `:` must be omitted
  - Types must be separated by the `+` sign
  - types are optional

  The struct returned by `build` should look like:
  %Stream.Name{category: "campaign", id: "123", types: ["command", "position"]}
  The function `to_string` should convert it back to
  `campaign:command+position-123`
  """

  @type t :: %Name{
          category: Delugex.StreamName.category(),
          id: Delugex.StreamName.id(),
          types: Delugex.StreamName.types()
        }

  defstruct(category: "", id: nil, types: [])

  def new(category), do: new(category, nil, [])
  def new(category, id), do: new(category, id, [])

  @spec new(
          category :: Delugex.StreamName.category(),
          id :: Delugex.StreamName.id(),
          types :: Delugex.StreamName.types()
        ) :: t()
  def new(category, id, types)
      when is_binary(category) and (is_nil(id) or is_binary(id)) and
             is_list(types) do
    %__MODULE__{category: category, id: id, types: types}
  end

  @doc """
  Creates a Name struct with a provided string as an arguement.

  ## Examples
      iex> Name.build("campaign:command+position-123")
      %Name{category: "campaign",
                        id: "123",
                        types: ["command", "position"]}
  """
  @spec build(text :: String.t()) :: Name.t()
  def build(text) when is_bitstring(text) do
    category = extract_category(text)
    {no_category, types_text, types} = extract_types(text, category)
    id = extract_id(no_category, types_text)

    new(category, id, types)
  end

  defp extract_category(string) do
    String.split(string, ":")
    |> List.first()
    |> String.split("-")
    |> List.first()
  end

  defp extract_types(string, category) do
    no_category =
      string
      |> String.trim_leading(category)
      |> String.trim_leading(":")

    types =
      no_category
      |> String.split("-")
      |> List.first()

    case types do
      "" -> {no_category, []}
      _ -> {no_category, types, String.split(types, "+")}
    end
  end

  defp extract_id(string, types_text) do
    id =
      string
      |> String.trim_leading(types_text)
      |> String.trim_leading("-")

    case id do
      "" -> nil
      _ -> id
    end
  end

  defimpl String.Chars do
    @spec to_string(stream_name :: Name.t()) :: String.t()
    def to_string(%Name{
          category: category,
          id: id,
          types: types
        }) do
      id = id_to_string(id)
      types = types_to_string(types)

      "#{category}#{types}#{id}"
    end

    defp id_to_string(nil), do: ""
    defp id_to_string(id), do: "-#{id}"

    defp types_to_string([]), do: ""
    defp types_to_string(types), do: ":#{Enum.join(types, "+")}"
  end

  defimpl Delugex.StreamName do
    def to_string(%Name{} = stream_name), do: Kernel.to_string(stream_name)
    def category(%Name{category: category}), do: category
    def id(%Name{id: id}), do: id
    def types(%Name{types: types}), do: types
    def category?(%Name{id: nil}), do: true
    def category?(%Name{id: id}) when not is_nil(id), do: false
  end
end
