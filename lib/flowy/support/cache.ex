defmodule Flowy.Support.Cache do
  @type t :: %__MODULE__{
          store: module(),
          opts: keyword()
        }

  @options [
    opts: [
      type: :non_empty_keyword_list,
      default: [ttl: 300],
      keys: [
        ttl: [
          default: 300,
          doc: "the time-to-live for a key in seconds. Default to 5 minutes.",
          type: :integer
        ]
      ]
    ],
    store: [
      default: Flowy.Support.Cache.MemoryStore,
      doc: "the cache store module to use.",
      type: :atom
    ]
  ]

  @moduledoc """
  The `Cache` module provides a simple API for interacting with the configured
  cache store.

  ### Options

  #{NimbleOptions.docs(@options)}
  """

  @type key :: String.t() | atom()
  @type cache :: Flowy.Support.Cache.t()

  defstruct [:store, :opts]

  alias Flowy.Telemetry

  @doc """
  Builds a cache struct.
  """
  @spec build(opts :: keyword()) :: cache
  def build(opts \\ []) do
    struct!(__MODULE__, options(opts))
  end

  @doc """
  Reads a value from the cache store using the default cache.
  """
  @spec read(key) :: any()
  def read(key) do
    build()
    |> read(key)
  end

  @spec read(key, opts :: keyword()) :: any()
  def read(key, opts) when is_atom(key) or is_binary(key) do
    build(opts: opts)
    |> read(key)
  end

  @doc """
  Reads a value from the cache store.
  """
  @spec read(cache, key) :: any()
  def read(%__MODULE__{store: store, opts: opts}, key) do
    Telemetry.event(:cache_read, %{}, %{key: key, store: store})
    store.read(key, opts)
  end

  @doc """
  Fetches a value from the cache store using the default cache.
  """
  @spec fetch(key, function()) :: any()
  def fetch(key, fnc) do
    build()
    |> fetch(key, fnc)
  end

  @doc """
  Fetches a value from the cache store. If the key does not exist, the function
  is called and the result is stored in the cache store.
  """
  @spec fetch(cache, key, function()) :: any()
  def fetch(%__MODULE__{store: store, opts: opts}, key, fnc) do
    Telemetry.event(:cache_fetched, %{}, %{key: key, store: store})
    store.fetch(key, fnc, opts)
  end

  @doc """
  Writes a value to the cache store using the default cache.
  """
  @spec write(key, any()) :: any()
  def write(key, value) do
    build()
    |> write(key, value)
  end

  @doc """
  Writes a value to the cache store.
  """
  @spec write(cache, key, any()) :: any()
  def write(%__MODULE__{store: store}, key, value) do
    Telemetry.event(:cache_wrote, %{}, %{key: key, store: store})
    store.write(key, value)
  end

  @doc """
  Deletes a value from the cache store using the default cache.
  """
  @spec delete(key) :: {:error, :not_found} | {:ok, :deleted}
  def delete(key) do
    build()
    |> delete(key)
  end

  @doc """
  Deletes a value from the cache store.
  """
  @spec delete(cache, key) :: {:error, :not_found} | {:ok, :deleted}
  def delete(%__MODULE__{store: store}, key) do
    Telemetry.event(:cache_deleted, %{}, %{key: key, store: store})
    store.delete(key)
  end

  defp options(opts) do
    NimbleOptions.validate!(opts, @options)
  end
end
