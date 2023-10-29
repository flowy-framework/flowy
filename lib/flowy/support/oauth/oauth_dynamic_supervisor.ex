defmodule Flowy.Support.OAuth.OAuthDynamicSupervisor do
  require Logger

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

  @spec start_link(any()) :: {:error, any()} | {:ok, pid()}
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
  @spec start_children() :: {:ok, [{:ok, pid()}]} | {:error, any()}
  def start_children do
    clients()
    |> log_children()
    |> start_children()

    :ok
  end

  defp log_children([]) do
    log_children(nil)
  end

  defp log_children(nil = clients) do
    Logger.info("OAuthDynamicSupervisor.start_children/0: no clients configured")
    clients
  end

  defp log_children(clients) do
    Logger.info("OAuthDynamicSupervisor.start_children # of clients: #{length(clients)}")
    clients
  end

  @doc """
  Start OAuthServer processes for each configured client.
  """
  @spec start_children([Flowy.Support.OAuth.Client.t()]) ::
          {:ok, [{:ok, pid()}]} | {:error, any()}
  def start_children([]), do: nil
  def start_children(nil), do: nil

  def start_children(clients) do
    pids =
      clients
      |> Enum.map(&start_child/1)

    {:ok, pids}
  end

  @doc """
  Start an OAuthServer process for a given client.
  """
  @spec start_child(Flowy.Support.OAuth.Client.t()) ::
          {:ok, pid()} | {:error, any()}
  def start_child(client) do
    case DynamicSupervisor.start_child(
           __MODULE__,
           # TODO: Explore the possibility of using a supervisor
           # that starts the OAuthServer instead of the dynamic supervisor
           # The dynamic supervisor could crash if one of the OAuthServer
           # doesn't start.
           {Flowy.Support.OAuth.OAuthServer, client}
         ) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, something} ->
        Logger.error("OAuthDynamicSupervisor.start_child/1: #{inspect(something)}")
        {:error, something}
    end
  end

  defp clients() do
    Application.fetch_env!(:flowy, :oauth)
    |> Keyword.get(:clients)
  end
end
