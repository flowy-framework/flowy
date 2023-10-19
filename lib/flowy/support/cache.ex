defmodule Flowy.Support.Cache do
  @moduledoc """
  The `Cache` module provides a simple API for interacting with the configured
  cache store.
  """

  @type key :: String.t() | atom()

  @spec read(key) :: any()
  @doc """
  Reads a value from the cache store.
  """
  @spec read(key, keyword()) :: any()
  def read(key, opts \\ []) do
    store = Keyword.get(opts, :store, store())
    read(store, key, opts)
  end

  @spec read(module(), key, keyword()) :: any()
  def read(store, key, opts) do
    store.read(key, opts)
  end

  @spec fetch(key, function()) :: any()
  @doc """
  Fetches a value from the cache store. If the key does not exist, the function
  is called and the result is stored in the cache store.
  """
  def fetch(key, fnc, opts \\ []) do
    store = Keyword.get(opts, :store, store())
    fetch(store, key, fnc, opts)
  end

  @spec fetch(module(), key, function(), keyword()) :: any()
  def fetch(store, key, fnc, opts) do
    store.fetch(key, fnc, opts)
  end

  @spec write(key, any()) :: any()
  @doc """
  Writes a value to the cache store.
  """
  def write(key, value) do
    store().write(key, value)
  end

  @spec write(module(), key, any()) :: {:ok, any()}
  def write(store, key, value) when is_atom(key) or is_binary(key) do
    store.write(key, value)
  end

  @spec delete(key) :: {:error, :not_found} | {:ok, :deleted}
  @doc """
  Deletes a value from the cache store.
  """
  def delete(key) do
    store().delete(key)
  end

  @spec delete(module(), key) :: {:error, :not_found} | {:ok, :deleted}
  def delete(store, key) do
    store.delete(key)
  end

  @doc false
  @spec store() :: module()
  def store do
    Application.get_env(:flowy, :cache)
    |> Keyword.fetch!(:store)
  end
end
