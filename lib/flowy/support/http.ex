defmodule Flowy.Support.Http do
  @type t :: %__MODULE__{
          client: module(),
          opts: keyword()
        }

  @type response :: Flowy.Support.Http.Response.t()

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
  The `Cache` module provides a simple API for interacting with the configured
  cache store.

  ### Options

  #{NimbleOptions.docs(@options)}
  """

  alias Flowy.Support.Http.Request

  @doc """
  Builds a new HTTP client struct.
  """
  @spec build(opts :: keyword()) :: t()
  def build(opts \\ []) do
    struct!(__MODULE__, options(opts))
  end

  @doc """
  Makes a GET request.
  """
  @spec get(url :: String.t(), headers :: keyword()) :: response
  def get(url, headers) do
    build()
    |> get(url, headers)
  end

  @spec get(t(), url :: String.t(), headers :: keyword()) :: response
  def get(%__MODULE__{client: client, opts: opts}, url, headers) do
    Request.build(
      :get,
      url,
      headers,
      nil,
      opts
    )
    |> client.request()
  end

  @doc """
  Makes a POST request.
  """
  @spec post(url :: String.t(), body :: map(), headers :: keyword()) :: response
  def post(url, body, headers) do
    build()
    |> post(url, body, headers)
  end

  @spec post(client :: t(), url :: String.t(), body :: map(), headers :: keyword()) :: response
  def post(%__MODULE__{client: client, opts: opts}, url, body, headers) do
    Request.build(
      :post,
      url,
      headers,
      body,
      opts
    )
    |> client.request()
  end

  @doc """
  Makes a PUT request.
  """
  @spec put(url :: String.t(), body :: map(), headers :: keyword()) :: response
  def put(url, body, headers) do
    build()
    |> put(url, body, headers)
  end

  @spec put(client :: t(), url :: String.t(), body :: map(), headers :: keyword()) :: response
  def put(%__MODULE__{client: client, opts: opts}, url, body, headers) do
    Request.build(
      :put,
      url,
      headers,
      body,
      opts
    )
    |> client.request()
  end

  @doc """
  Makes a PATCH request.
  """
  @spec patch(url :: String.t(), body :: map(), headers :: keyword()) :: response
  def patch(url, body, headers) do
    build()
    |> patch(url, body, headers)
  end

  @spec patch(client :: t(), url :: String.t(), body :: map(), headers :: keyword()) :: response
  def patch(%__MODULE__{client: client, opts: opts}, url, body, headers) do
    Request.build(
      :patch,
      url,
      headers,
      body,
      opts
    )
    |> client.request()
  end

  @doc """
  Makes a DELETE request.
  """
  @spec delete(url :: String.t(), headers :: keyword()) :: response
  def delete(url, headers) do
    build()
    |> delete(url, headers)
  end

  @spec delete(client :: t(), url :: String.t(), headers :: keyword()) :: response
  def delete(%__MODULE__{client: client, opts: opts}, url, headers) do
    Request.build(
      :delete,
      url,
      headers,
      nil,
      opts
    )
    |> client.request()
  end

  defp options(opts) do
    NimbleOptions.validate!(opts, @options)
  end
end
