defmodule <%= @web_namespace %>.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      <%= @web_namespace %>.Telemetry,
      # Start a worker by calling: <%= @web_namespace %>.Worker.start_link(arg)
      # {<%= @web_namespace %>.Worker, arg},
      # Start to serve requests, typically the last entry
      <%= @endpoint_module %>
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: <%= @web_namespace %>.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    <%= @endpoint_module %>.config_change(changed, removed)
    :ok
  end
end
