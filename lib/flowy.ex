defmodule Flowy do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  use GenServer

  alias Flowy.Config

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  @spec init(keyword()) :: {:ok, Flowy.Config.t()}
  @doc false
  def init(opts) do
    config = Config.build(opts)

    {:ok, config}
  end

  def config() do
    GenServer.call(__MODULE__, :config)
  end

  @impl true
  def handle_call(:config, _from, config) do
    {:reply, config, config}
  end
end
