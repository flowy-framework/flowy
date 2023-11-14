defmodule Flowy.Web.Plugs.JwtAuthPlug do
  @moduledoc """
    Looks for and validates a token found in the `Authorization` header.
  """
  import Plug.Conn
  require Logger
  alias Flowy.Utils.JwtToken
  alias Flowy.Utils.JwtToken.OIDCConfig

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
  defp send_error(conn, error) do
    Logger.error("JwtAuthPlug Error: #{inspect(error)}")

    body =
      error_body(error_code())

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, body)
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

  defp error_code(), do: Flowy.config().service.codes |> Keyword.get(:"403")

  defp error_body(%{code: code, description: description}) do
    %{errors: [%{error_code: code, error_message: description}]}
    |> Jason.encode!()
  end
end
