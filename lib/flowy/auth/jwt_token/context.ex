defmodule Flowy.Auth.JwtToken.Context do
  @moduledoc """
  This module is responsible for decoding and verifying a JWT token
  """
  @type t :: %__MODULE__{
          token: String.t(),
          claims: [Joken.Claim.t()]
        }

  defstruct token: nil, claims: []

  @doc """
  Builds a context struct with the token and the claims
  """
  @spec build(any(), keyword()) :: %Flowy.Auth.JwtToken.Context{
          claims: [Joken.Claim.t()],
          token: String.t()
        }
  def build(token, opts \\ []) do
    # https://github.com/jwtk/jjwt/issues/77
    claims =
      opts
      |> Keyword.get(:aud, nil)
      |> aud_array?()
      |> claims(opts)

    %__MODULE__{
      token: token,
      claims: claims
    }
  end

  defp claims(false = _aud_array, opts) do
    Joken.Config.default_claims(opts)
  end

  defp claims(true = _aud_array, opts) do
    skip = Keyword.get(opts, :skip, []) ++ [:aud]
    opts = Keyword.merge(opts, skip: skip)
    {aud, opts} = Keyword.pop(opts, :aud)

    Joken.Config.default_claims(opts)
    |> Joken.Config.add_claim("aud", fn -> aud end, fn incoming ->
      validate_audience(incoming, aud)
    end)
  end

  defp aud_array?(aud) when is_list(aud), do: true
  defp aud_array?(_aud), do: false

  @doc """
  Compares the audience from the token with the audience to validate
  """
  @spec validate_audience(String.t(), maybe_improper_list()) :: boolean()
  def validate_audience(aud_from_token, aud_to_validate)
      when is_list(aud_to_validate) do
    aud_to_validate == aud_from_token
  end

  @spec validate_audience(any()) :: false
  def validate_audience(_), do: false

  # def build(token, claims, opts \\ []) do
  #   %__MODULE__{token: token, claims: claims}
  # end

  defdelegate default_claims(defaults \\ []), to: Joken.Config
end
