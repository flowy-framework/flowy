defmodule Flowy.Support.Http do
  @type t :: %__MODULE__{
          client: module(),
          opts: keyword()
        }

  @type response :: {:ok, Flowy.Support.Http.Response.t()} | {:error, Flowy.Support.Http.Response.t()}

  defstruct [:client, :opts]

  @options [
    opts: [
      type: :non_empty_keyword_list,
      default: [receive_timeout: 15_000],
      keys: [
        receive_timeout: [
          default: 15_000,
          doc: "The maximum time to wait for a response before returning an error",
          type: :integer
        ],
        pool_timeout: [
          default: 5_000,
          doc: "This timeout is applied when we check out a connection from the pool.",
          type: :integer
        ]
      ]
    ],
    client: [
      default: Flowy.Support.Http.FinchClient,
      doc: "the HTTP client module to use.",
      type: :atom
    ]
  ]

  @moduledoc """
  The `Http` module provides a simple API for interacting with the configured
  http client.

  ### Options

  #{NimbleOptions.docs(@options)}
  """

  alias Flowy.Support.Http.Request

  @doc """
  Builds a new HTTP client struct.

  ## Examples

    iex> Flowy.Support.Http.build()
    %Flowy.Support.Http{
      client: Flowy.Support.Http.FinchClient,
      opts: [pool_timeout: 5000, receive_timeout: 15000]
    }

    iex> Flowy.Support.Http.build(opts: [receive_timeout: 10_000])
    %Flowy.Support.Http{
      client: Flowy.Support.Http.FinchClient,
      opts: [pool_timeout: 5000, receive_timeout: 10000]
    }
  """
  @spec build(opts :: keyword()) :: t()
  def build(opts \\ []) do
    struct!(__MODULE__, options(opts))
  end

  @doc """
  Makes a GET request.
  """
  @spec get(url :: String.t(), headers :: list()) :: response
  def get(url, headers) do
    build()
    |> get(url, headers)
  end

  @doc """
  Makes a GET request, using the provided client.
  """
  @spec get(t(), url :: String.t(), headers :: list()) :: response
  def get(module, url, headers) do
    do_request(
      module,
      :get,
      url,
      headers
    )
  end

  @doc """
  Makes a POST request.
  """
  @spec post(url :: String.t(), body :: map(), headers :: list()) :: response
  def post(url, body, headers) do
    build()
    |> post(url, body, headers)
  end

  @doc """
  Makes a POST request, using the provided client.
  """
  @spec post(client :: t(), url :: String.t(), body :: map(), headers :: list()) :: response
  def post(module, url, body, headers) do
    do_request(
      module,
      :post,
      url,
      headers,
      body
    )
  end

  @doc """
  Makes a PUT request.
  """
  @spec put(url :: String.t(), body :: map(), headers :: list()) :: response
  def put(url, body, headers) do
    build()
    |> put(url, body, headers)
  end

  @doc """
  Makes a PUT request, using the provided client.
  """
  @spec put(client :: t(), url :: String.t(), body :: map(), headers :: list()) :: response
  def put(module, url, body, headers) do
    do_request(
      module,
      :put,
      url,
      headers,
      body
    )
  end

  @doc """
  Makes a PATCH request.
  """
  @spec patch(url :: String.t(), body :: map(), headers :: list()) :: response
  def patch(url, body, headers) do
    build()
    |> patch(url, body, headers)
  end

  @doc """
  Makes a PATCH request, using the provided client.
  """
  @spec patch(client :: t(), url :: String.t(), body :: map(), headers :: list()) :: response
  def patch(module, url, body, headers) do
    do_request(
      module,
      :patch,
      url,
      headers,
      body
    )
  end

  @doc """
  Makes a DELETE request.
  """
  @spec delete(url :: String.t(), headers :: list()) :: response
  def delete(url, headers) do
    build()
    |> delete(url, headers)
  end

  @doc """
  Makes a DELETE request, using the provided client.
  """
  @spec delete(client :: t(), url :: String.t(), headers :: list()) :: response
  def delete(module, url, headers) do
    do_request(
      module,
      :delete,
      url,
      headers
    )
  end

  @spec do_request(t(), atom(), String.t(), list()) :: response
  def do_request(%__MODULE__{client: client, opts: opts}, method, url, headers) do
    meta = build_meta(method, url)

    start_time =
      Flowy.Telemetry.start(:http, meta)

    result =
      Request.build(
        method,
        url,
        headers,
        nil,
        opts
      )
      |> client.request()

    Flowy.Telemetry.stop(:http, start_time, meta)
    result
  end

  @spec do_request(t(), atom(), String.t(), list(), map()) :: response
  def do_request(%__MODULE__{client: client, opts: opts}, method, url, headers, body) do
    meta = build_meta(method, url)

    start_time =
      Flowy.Telemetry.start(:http, meta)

    result =
      Request.build(
        method,
        url,
        headers,
        body,
        opts
      )
      |> client.request()

    Flowy.Telemetry.stop(:http, start_time, meta)
    result
  end

  defp options(opts) do
    NimbleOptions.validate!(opts, @options)
  end

  defp build_meta(method, uri) do
    build_uri(uri)
    |> Map.merge(%{method: method |> Atom.to_string()})
  end

  defp build_uri(url) do
    uri = URI.parse(url)

    %{
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      query: uri.query
    }
  end
end
