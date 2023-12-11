defmodule Flowy.Utils.JwtToken do
  @moduledoc """
  This module is responsible for decoding and verifying a JWT token
  """

  alias Joken.Signer
  alias Flowy.Utils.JwtToken.{OIDCConfig, Context}
  alias Flowy.Support.{Http, Cache}

  @doc """
  Decodes and verifies a JWT token using the public keys found in the JWKS endpoint
  """
  @spec decode_and_validate(Flowy.Utils.JwtToken.Context.t(), keyword()) ::
          {:error, String.t()} | {:ok, map()}
  def decode_and_validate(context, opts \\ [])
  def decode_and_validate(%Context{} = context, opts), do: decode(context, opts)

  def decode_and_validate(token, opts) when is_binary(token),
    do: decode(Context.build(token, opts), opts)

  def decode_and_validate(_, _), do: {:error, "No token provided"}

  @spec decode(Flowy.Utils.JwtToken.Context.t(), keyword()) ::
          {:error, String.t()} | {:ok, map()}
  def decode(context, opts \\ [])
  def decode(nil, _opts), do: {:error, "No token provided"}

  def decode(token, opts) when is_binary(token),
    do: Context.build(token, opts) |> decode(opts)

  def decode(%Context{} = context, opts) do
    with {:ok, public_keys} <- public_keys(opts),
         {:ok, verified} <- verify_with_keys(context, public_keys) do
      {:ok, verified}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Signs a JWT token using the private key found in the PEM file
  This is mainly used to generate a token for testing purposes
  """
  @spec sign() :: {:ok, String.t(), map()}
  def sign() do
    rs256_config = %{"pem" => OIDCConfig.pem()}
    signer = Joken.Signer.create("RS256", rs256_config)

    {:ok, claims} =
      Joken.generate_claims(%{}, %{"iss" => OIDCConfig.iss(), "aud" => [OIDCConfig.aud()]})

    Joken.encode_and_sign(claims, signer)
  end

  @doc """
  Signs a JWT token using the private key found in the PEM file
  """
  @spec sign!() :: String.t()
  def sign!() do
    {:ok, token, _claims} = sign()
    token
  end

  # Helper function to try multiple public keys
  defp verify_with_keys(_, []), do: {:error, "No valid public key found"}

  defp verify_with_keys(context, [key | remaining_keys]) do
    case verify_with_key(context, key) do
      {:ok, verified} ->
        {:ok, verified}

      {:error, [{:message, message}, {:claim, claim} | _rest]} ->
        {:error, "#{message}: #{claim}"}

      _ ->
        verify_with_keys(context, remaining_keys)
    end
  end

  # Helper function to verify a JWT token with a single public key
  defp verify_with_key(context, key) do
    Joken.verify_and_validate(context.claims, context.token, Signer.create("RS256", key))
  end

  @doc """
  Fetches the public keys from the JWKS endpoint
  """
  @spec public_keys(keyword()) :: map()
  def public_keys(opts) do
    # 1 hour by default
    ttl = opts |> Keyword.get(:ttl, 60 * 60)

    Cache.fetch(
      :public_keys,
      fn ->
        case OIDCConfig.public_keys() do
          %{"keys" => keys} ->
            keys

          _ ->
            {:ok, %{body: %{"keys" => keys}}} =
              Http.get(public_keys_url(opts), headers())

            keys
        end
      end,
      ttl: ttl
    )
  end

  @spec public_keys_url(keyword()) :: String.t()
  def public_keys_url(opts) do
    opts
    |> Keyword.get(:uri, OIDCConfig.jwks_uri())
  end

  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]
  end
end
