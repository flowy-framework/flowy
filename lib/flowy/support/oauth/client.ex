defmodule Flowy.Support.OAuth.Client do
  @moduledoc """
  This module is responsible for managing the OAuth clients.
  """

  @type t :: %__MODULE__{
          client_id: String.t(),
          client_secret: String.t(),
          audience: String.t(),
          site: String.t(),
          scopes: [String.t()],
          token_url: String.t(),
          access_token: OAuth2.AccessToken.t(),
          oauth_client: OAuth2.Client.t()
        }

  defstruct client_id: "",
            client_secret: "",
            audience: "http://0.0.0.0:8000",
            site: "",
            token_url: "/oauth2/token",
            oauth_client: nil,
            scopes: [],
            access_token: nil

  @doc """
  Remove the access token from the client. This is used
  when the token is expired or invalid.
  """
  def reset_access_token(client) do
    %{client | access_token: nil}
  end
end
