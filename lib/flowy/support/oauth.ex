defmodule Flowy.Support.OAuth do
  @moduledoc """
  This module is responsible for managing the OAuth clients.

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
  alias OAuth2.AccessToken

  @doc """
  This function is responsible for building the OAuth client.
  """
  @spec build(Flowy.Support.OAuth.Client.t()) :: Flowy.Support.OAuth.Client.t()
  def build(%Flowy.Support.OAuth.Client{} = client) do
    build(
      client.client_id,
      client.client_secret,
      client.audience,
      client.site,
      client.token_url,
      client.scopes
    )
  end

  def build(%{
        client_id: client_id,
        client_secret: client_secret,
        audience: audience,
        site: site,
        token_url: token_url,
        scopes: scopes
      }) do
    build(client_id, client_secret, audience, site, token_url, scopes)
  end

  def build(%{
        "client_id" => client_id,
        "client_secret" => client_secret,
        "audience" => audience,
        "site" => site,
        "token_url" => token_url,
        "scopes" => scopes
      }) do
    build(client_id, client_secret, audience, site, token_url, scopes)
  end

  @spec build(String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
          Flowy.Support.OAuth.Client.t()
  def build(client_id, client_secret, audience, site, token_url, scopes) do
    oauth = %Flowy.Support.OAuth.Client{
      client_id: client_id,
      client_secret: client_secret,
      site: site,
      token_url: token_url || "/oauth2/token",
      audience: audience,
      scopes: scopes
    }

    client =
      OAuth2.Client.new(
        strategy: OAuth2.Strategy.ClientCredentials,
        client_id: client_id,
        client_secret: client_secret,
        site: site,
        token_url: token_url
      )

    %{oauth | oauth_client: client}
  end

  @doc """
  This function is responsible for getting the access token from the OAuth server.
  When the client already have an access token, it will check if the token is expired.
  """
  @spec get_token(Flowy.Support.OAuth.Client.t()) :: OAuth2.AccessToken.t()
  def get_token(
        %Flowy.Support.OAuth.Client{access_token: %{} = access_token} =
          client
      ) do
    if expired?(access_token) do
      client
      |> Flowy.Support.OAuth.Client.reset_access_token()
      |> get_token()
    else
      access_token
    end
  end

  @spec get_token(Flowy.Support.OAuth.Client.t()) :: OAuth2.AccessToken.t()
  def get_token(%Flowy.Support.OAuth.Client{oauth_client: oauth_client} = handler) do
    joined_scopes =
      handler.scopes
      |> parse_scopes()

    client =
      oauth_client
      |> OAuth2.Client.put_serializer("application/json", Jason)
      |> OAuth2.Client.get_token!(scope: joined_scopes, audience: handler.audience)

    client.token
  end

  @spec get_access_token(Flowy.Support.OAuth.Client.t()) :: String.t()
  def get_access_token(%Flowy.Support.OAuth.Client{} = client) do
    client
    |> get_token()
    |> Map.get(:access_token)
  end

  defp expired?(token) do
    token
    |> AccessToken.expired?()
  end

  defp parse_scopes(scopes) when is_binary(scopes), do: scopes

  defp parse_scopes(scopes) when is_list(scopes) do
    scopes
    |> Enum.join(" ")
  end
end
