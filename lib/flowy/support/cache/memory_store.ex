defmodule Flowy.Support.Cache.MemoryStore do
  @moduledoc """
  A simple in-memory cache store backed by ETS

  ## Options

  * `ttl` - the time-to-live for a key in seconds. Default to 5 minutes.
  """

  @behaviour Flowy.Support.Cache.Store

  use GenServer

  @table :flowy_memory_store
  # 5 minutes
  @default_ttl 5 * 60

  @doc false
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  @doc false
  def init(_) do
    # gives us key=>value semantics
    :ets.new(@table, [
      :set,

      # allows any process to read/write to our table
      :public,

      # allow the ETS table to access by it's name, `@table`
      :named_table,

      # favor read-locks over write-locks
      read_concurrency: true,

      # internally split the ETS table into buckets to reduce
      # write-lock contention
      write_concurrency: true
    ])

    {:ok, nil}
  rescue
    ArgumentError -> {:error, :already_started}
  end

  @doc """
  Read a value from the cache.
  """
  @impl Flowy.Support.Cache.Store
  @spec read(String.t(), keyword()) :: {:error, :expired | :not_found} | {:ok, any()}
  def read(key, opts \\ []) do
    ttl = Keyword.get(opts, :ttl, @default_ttl)

    case :ets.lookup(@table, key) do
      [{_key, value, ts}] ->
        if timestamp() - ts <= ttl do
          {:ok, value}
        else
          {:error, :expired}
        end

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Fetch a value from the cache, or write the result of the function to the cache
  if the key does not exist.
  """
  @impl Flowy.Support.Cache.Store
  @spec fetch(String.t(), fun(), keyword()) :: {:ok, any()}
  def fetch(key, fnc, opts \\ []) do
    case read(key, opts) do
      {:ok, value} ->
        {:ok, value}

      {:error, _} ->
        write(key, fnc.())
    end
  end

  @impl Flowy.Support.Cache.Store
  @spec write(String.t(), any()) :: {:ok, any()}
  @doc """
  Write a value to the cache
  """
  def write(key, value) do
    true = :ets.insert(@table, {key, value, timestamp()})

    {:ok, value}
  end

  @spec delete(String.t()) :: {:error, :not_found} | {:ok, :deleted}
  @impl Flowy.Support.Cache.Store
  @doc """
  Delete a value from the cache
  """
  def delete(key) do
    case :ets.lookup(@table, key) do
      [{_key, _value, _ts}] ->
        true = :ets.delete(@table, key)
        {:ok, :deleted}

      _ ->
        {:error, :not_found}
    end
  end

  # Return current timestamp
  defp timestamp, do: DateTime.to_unix(DateTime.utc_now())
end
