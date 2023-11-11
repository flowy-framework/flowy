defmodule Flowy.Auth.JwtToken.OIDCConfig do
  @moduledoc """
  OIDC configuration to be used with JWT Token authentication
  """

  @doc """
  Returns the PEM file to be used to verify the JWT token from
  an environment variable called OIDC_PEM or from the settings :flowy, :pem
  """
  def pem() do
    get_value("OIDC_PEM", :pem, "")
    |> String.replace("\\n", "\n")
  end

  @doc """
  Returns the public keys to be used to verify the JWT token from
  an environment variable called OIDC_PUBLIC_KEYS
  """
  def public_keys() do
    get_value("OIDC_PUBLIC_KEYS", :public_keys, "{}")
    |> Jason.decode!()
  end

  @doc """
  Returns the issuer of the JWT token from
  an environment variable called OIDC_ISS
  """
  def iss() do
    get_value("OIDC_ISS", :iss)
  end

  @doc """
  Returns the audience of the JWT token from
  an environment variable called OIDC_AUD
  """
  def aud() do
    get_value("OIDC_AUD", :aud)
  end

  @doc """
  Returns the JWKS URI of the JWT token from
  an environment variable called OIDC_JWKS_URI
  """
  def jwks_uri() do
    get_value("OIDC_JWKS_URI", :jwks_uri)
  end

  @doc """
  Returns the default claims for the JWT token
  """
  def claims(opts \\ []) do
    iss = Keyword.get(opts, :iss, iss())
    aud = Keyword.get(opts, :aud, aud()) |> split()
    skip = Keyword.get(opts, :skip, [])

    # aud from hydra tokens are arrays, not strings, so we need to handle that
    [
      iss: iss,
      aud: aud,
      skip: skip
    ]
  end

  defp split(nil), do: nil
  defp split(aud), do: String.split(aud, ",")

  defp get_value(env_var, key, default \\ "") do
    from_env(env_var) || from_settings(key) || default ||
      raise "Missing value for #{env_var}/#{key}"
  end

  defp from_env(key) do
    System.get_env(key)
  end

  defp from_settings(key) do
    Application.get_env(:flowy, :oidc, [])
    |> Keyword.get(key)
  end
end
