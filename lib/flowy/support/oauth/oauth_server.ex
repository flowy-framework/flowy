defmodule Flowy.Support.OAuth.OAuthServer do
  require Logger

  @moduledoc """
  This module is responsible for managing the OAuth clients.
  """
  use GenServer

  def start_link(%{client_id: client_id} = client) do
    Logger.info("OAuthServer.start_link/1: #{client_id}")
    GenServer.start_link(__MODULE__, client, name: name(client_id))
  end

  @impl true
  @spec init(map()) :: {:ok, Flowy.Support.OAuth.Client.t()}
  def init(%{client_id: client_id} = client) do
    oauth_client =
      client
      |> Flowy.Support.OAuth.build()

    Logger.info("OAuthServer.init: #{client_id} configured")
    {:ok, oauth_client}
  end

  def token(client_id) do
    try do
      GenServer.call(name(client_id), :token)
    catch
      :exit, e ->
        {:error, e}
    end
  end

  def stop(client_id) do
    GenServer.call(name(client_id), :halt_and_cleanup)
  end

  @impl true
  def handle_call(:token, _from, client) do
    %{access_token: access_token} = access_token_mod = Flowy.Support.OAuth.get_token(client)
    client = %{client | access_token: access_token_mod}
    {:reply, {:ok, access_token}, client}
  end

  @impl true
  def handle_call(:halt_and_cleanup, _from, client) do
    {:stop, :normal, client}
  end

  defp name(client_id) do
    :"oauth_server_#{client_id}"
  end
end
