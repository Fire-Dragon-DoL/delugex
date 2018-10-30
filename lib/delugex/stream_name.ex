defprotocol Delugex.StreamName do
  @moduledoc """
  StreamName is a module to manage the location where events are written.
  Stream names could be intended as URLs for where events are located.
  The StreamName protocol provides an easy way to access the data that
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

  The struct coming out of `build` should look like:
  %StreamName{category: "campaign", id: "123", types: ["command", "position"]}
  The function `to_string` should convert it back to
  `campaign:command+position-123`
  """

  @type category :: String.t()
  @type id :: String.t() | nil
  @type types :: [String.t()]

  @doc "Converts a StreamName into a string to be supplied to the database"
  @spec to_string(stream_name) :: String.t()
  def to_string(stream_name)

  @doc "Extracts category from a StreamName"
  @spec category(stream_name) :: category()
  def category(stream_name)

  @doc "Extracts id from a StreamName"
  @spec id(stream_name) :: id()
  def id(stream_name)

  @doc "Extracts types from a StreamName"
  @spec types(stream_name) :: types()
  def types(stream_name)

  @doc "true if the stream_name has nil id"
  @spec category?(stream_name) :: boolean()
  def category?(stream_name)
end