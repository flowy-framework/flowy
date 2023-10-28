defmodule Flowy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Flowy.Support.OAuth.OAuthDynamicSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Flowy.Worker.start_link(arg)
      # TODO: Once we add another http client, we will want to
      # move this out of here and into the host application.
      {Finch, name: Flowy.Finch},
      {Flowy.Support.OAuth.OAuthDynamicSupervisor,
       strategy: :one_for_one, name: Flowy.Support.OAuth.OAuthDynamicSupervisor},
      # TODO: Explore other alternatives to this approach
      {Task, &OAuthDynamicSupervisor.start_children/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flowy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
