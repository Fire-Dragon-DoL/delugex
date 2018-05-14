defmodule EspEx.EventBus.Postgres.Notifications do
  @doc """
  listen will start listening for a specific stream name using Postgres LISTEN.
  Check Postgrex to see how to use Postgres LISTEN
  """
  @spec listen(binary) :: {:ok, reference}
  def listen(channel) do
    {:ok, ref} = Postgrex.Notifications.listen(Postgrex.Notifications, channel)
  end

  @spec notify(binary, binary) :: :ok
  def notify(channel, data) do
    sql = "select pg_notify($1, $2)"
    Ecto.Adapters.SQL.query!(EspEx.Repo, sql, [channel, data])
    :ok
  end

  @spec unlisten(reference, binary) :: :ok
  def unlisten(ref, channel) do
    Postgrex.Notifications.unlisten!(Postgrex.Notifications, ref)
  end
end
