defmodule EspEx.Application do
  use Application

  def start(_type, _args) do
    children = [
      EspEx.Repo,
      #    {Postgrex.Notifications, EspEx.Repo.config}
      %{
        id: Postgrex.Notifications,
        start:
          {Postgrex.Notifications, :start_link,
           [EspEx.Repo.config() ++ [name: Postgrex.Notifications]]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: EspEx.Application)
  end
end
