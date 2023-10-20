defmodule Flowy.Support.Cache.Store do
  @moduledoc """
  A behaviour for cache stores.
  """
  @callback read(key :: String.t(), opts :: keyword) ::
              {:ok, any()} | {:error, :expired | :not_found}
  @callback fetch(key :: String.t(), fnc :: fun(), opts :: keyword) ::
              {:ok, any()} | {:error, :expired | :not_found}
  @callback write(key :: String.t(), value :: any()) :: {:ok, any()}
  @callback delete(key :: String.t()) :: {:error, :not_found} | {:ok, :deleted}
end
