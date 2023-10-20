defmodule Flowy.Support.OAuth.OAuthDynamicSupervisor do
  @moduledoc """
  This supervisor is responsible for starting all the OAuthServer processes.

  ## Configuration

  ```elixir
  config :flowy, :oauth,
    site: "https://hydra.mysite.net",
    clients: [
      %{
        client_id: System.get_env("APP_CLIENT_ID"),
        client_secret: System.get_env("APP_SECRET"),
        audience: System.get_env(" APP_AUDIENCE"),
        token_url: "/oauth2/token",
        scopes: []
      }
    ]
  ```
  """

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  We want to starts all the existing GRPC connections
  when the supervisor starts. But we want to do it in a
  Task so we don't block the supervisor.
  """
  def start_children do
    Application.fetch_env!(:flowy, :oauth)
    |> start_children()

    :ok
  end

  def start_children([]), do: nil
  def start_children(nil), do: nil

  def start_children(clients) do
    clients
    |> Enum.each(&start_child/1)

    :ok
  end

  def start_child(client) do
    DynamicSupervisor.start_child(
      __MODULE__,
      # TODO: Explore the possibility of using a supervisor
      # that starts the OAuthServer instead of the dynamic supervisor
      # The dynamic supervisor could crash if one of the OAuthServer
      # doesn't start.
      {Flowy.Support.OAuth.OAuthServer, client}
    )
  end
end
