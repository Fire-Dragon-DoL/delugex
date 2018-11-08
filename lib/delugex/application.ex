defmodule Delugex.Application do
  use Application

  def start(_type, _args) do
    children = [
      Delugex.MessageStore.Postgres
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Delugex.Application
    )
  end
end
