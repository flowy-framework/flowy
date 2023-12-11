defmodule Flowy.Web.Plugs.JwtAuthPlug do
  @moduledoc """
    Looks for and validates a token found in the `Authorization` header.

    ## Example configuration

    ```
    config :flowy, :oidc,
      pem:
        "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCr96qoCcY3UQ3q\nGPW7tFMRPvfx0pwb2zyJ3qXIQdcbew0y2dzQRXcPoBoOYb6oo8XqnJEPYRY5itvm\nEkIqElkKJhbxMHARCKbz5klViEUIoGWdP4m0stdIDfb9ej+KEgki9jbWXM/DRnnd\nPzPKwWYQixo4R9ykKgE5qoFosEZcyn9itpXhukUYhdGxnV/f3iBH/osVApwmk49C\nEFIYKBem/Xks2BdETXdRSWA49BXCzUDlcu2lSiMCkpcSIUUv1bJx10uwqiLwJVIP\n5nFRgLp/m61Eczr4DEqeqkDR5Ix9O0pPc3ufnszlaVsAH075qG5WQYPMIsywG3mr\ncyXQ7L6VAgMBAAECggEAWijnWGKHgckFOo8LhvXr90bESAzbu98dxkrtMCkU1luV\nd+uxUaCZ459VCeVFSLVUtsSPaTjFpjWfROidt+EWvbNqo9l5Z/TZU1aRbD6dswAl\nRmRhllONe0GXFR5a4dDC6YmdBpZydzcj/VN9m/f5wwKrJIbIr2k2az1xy6lfupWx\nD2+wNNZ3QKrRc9hHADMdiiY/kPhAlslmnmsNWhWVCdmt5uDd2l8jLZulSispz/dN\nZJfV4KV0+m1EzVX1AlxaaNRJVba6DDIwW3ValDsfR6fs3wSY3Se1m3hTlD260ZZc\nyxiZPD0HaFXs1JgWolDA9iPmCoBtr5xLqTX+3Qy8AQKBgQD5jrRtTlASqubOOLGX\nGkqSydwkV6Vl409Y7Prjn25/0Zqgz67oCrvok1lZKEJ0Kbe0wBmviHg0lBODlNjb\nytKkVW9nmXjXIIsuPIggBVPeFfsmroMQFLdOBFQEKc3h+CqK0WuBSJkSfprC18nJ\nuIfQ6t5RMQpjGtNAeb4isYOFoQKBgQCwaC3Kmx0ZKZjrC2pNgbslkDnQIDBwBsDd\nKnRLFoj2bft+TD4R/qR4aiSTsBJ1WS4fwabE7wTpILI45sMAAxJ1Aj/SIoRTmOnb\nPsrP01CoLbsTUa4vwzN39bm5MgC9HxLn5KEg3ihzQPpsr/Tgyd0tnDoKJYH4Vbqy\n3WoW1DksdQKBgQC7Ydy2SlwzeCGv7L/kHniqOWnT2/+0Pnbg5agI7DhzPzZk0yyY\nzR6FJsaq/GDRilWHIcrnk4f2qszwOv6OIoABpqjs2D71AVmgURFBQd7UXhrj05tT\nosp0iSlwqtcNemKvM0oOnC1bxrZ74L2Ces14IDLoMfODsKu4uPD8ad/AoQKBgQCD\npBqX2Qzr3BjbPdeEI02PCIO8BmlfEAsYgDfsWNK4YvaMF0UylH4TxdGpzHjZzUUY\nOaDD0UIu3lFhGQNnnONHIfiSTWPGJpRNIhyi3iSQfB/gmNGNnvNnj52az++xMeEf\n34NGTcKNz22RcfUhUkKVaMH/FGJa+U6rb4Ndqd1IiQKBgQD0vg5zIHkyulJAa/84\nWI3bJ47K2B4aChjxSxSAlErkaxtxUNkKGAYET0KQppr9lB3YlMLaMOPNEspsx9Y/\nUe3hHntIf7FCe1eTzLXitahZQCTA2EDB3A+l7/C/BsZYlPLbA0tB0dUUBLTW8jOR\nmqyulmffKbN848GkbOF0z/ydqQ==\n-----END PRIVATE KEY-----\n",
      public_keys:
        "{\"keys\":[{\"kty\":\"RSA\",\"e\":\"AQAB\",\"use\":\"sig\",\"kid\":\"iTMxG6ONYMk-jsWFa8MwwG_BvTeNQRaRqTpcPBt8J3g\",\"alg\":\"RS256\",\"n\":\"q_eqqAnGN1EN6hj1u7RTET738dKcG9s8id6lyEHXG3sNMtnc0EV3D6AaDmG-qKPF6pyRD2EWOYrb5hJCKhJZCiYW8TBwEQim8-ZJVYhFCKBlnT-JtLLXSA32_Xo_ihIJIvY21lzPw0Z53T8zysFmEIsaOEfcpCoBOaqBaLBGXMp_YraV4bpFGIXRsZ1f394gR_6LFQKcJpOPQhBSGCgXpv15LNgXRE13UUlgOPQVws1A5XLtpUojApKXEiFFL9WycddLsKoi8CVSD-ZxUYC6f5utRHM6-AxKnqpA0eSMfTtKT3N7n57M5WlbAB9O-ahuVkGDzCLMsBt5q3Ml0Oy-lQ\"}]}",
      iss: "https://local.dev/",
      aud: "https://flowy.local.dev",
      jwks_uri: "http://localhost/jwks"
    ```

    And add your plug to to your API pipeline:

    ```
    pipeline :api do
      plug :accepts, ["json"]
      plug Flowy.Web.Plugs.CamelCaseDecoderPlug
      plug Flowy.Web.Plugs.JwtAuthPlug
      ....
    end
    ```
  """
  import Plug.Conn
  alias Flowy.Web.Controllers.ErrorJSON
  alias Flowy.Utils.JwtToken
  alias Flowy.Utils.JwtToken.OIDCConfig
  alias Phoenix.Controller

  @behaviour Plug

  @impl Plug
  @spec init(opts :: Keyword.t()) :: Keyword.t()
  def init(opts \\ []), do: opts

  @impl Plug
  def call(conn, opts) do
    opts =
      OIDCConfig.claims()
      |> Keyword.merge(opts)

    # TODO: mergear las opts por default
    with {:ok, token} <- fetch_token_from_header(conn, opts),
         {:ok, _claims} <- JwtToken.decode_and_validate(token, opts) do
      conn
    else
      {_, error} ->
        conn
        |> send_error(error)
    end
  end

  # Sends an error response with the given code and message.
  defp send_error(conn, _error) do
    # TODO: Do we want to send it to the logs or tracing?
    # Logger.error("JwtAuthPlug Error: #{inspect(error)}")

    conn
    |> put_resp_content_type("application/json")
    |> put_status(403)
    |> Controller.put_view(ErrorJSON)
    |> Controller.render("403.json", %{})
    |> halt()
  end

  @spec fetch_token_from_header(Plug.Conn.t(), Keyword.t()) :: :no_token_found | {:ok, String.t()}
  defp fetch_token_from_header(conn, opts) do
    header_name = Keyword.get(opts, :header_name, "authorization")
    headers = get_req_header(conn, header_name)
    fetch_token_from_header(conn, opts, headers)
  end

  @spec fetch_token_from_header(Plug.Conn.t(), Keyword.t(), Keyword.t()) ::
          {:error, :no_token_found} | {:ok, String.t()}
  defp fetch_token_from_header(_, _, []), do: {:error, :no_token_found}

  defp fetch_token_from_header(conn, opts, [token | tail]) do
    reg = Keyword.get(opts, :scheme_reg, ~r/Bearer\s+(.*)/)
    trimmed_token = String.trim(token)

    case Regex.run(reg, trimmed_token) do
      [_, match] -> {:ok, String.trim(match)}
      _ -> fetch_token_from_header(conn, opts, tail)
    end
  end
end
