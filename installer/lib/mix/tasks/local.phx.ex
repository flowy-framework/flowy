defmodule Mix.Tasks.Local.Flowy do
  use Mix.Task

  @shortdoc "Updates the Flowy project generator locally"

  @moduledoc """
  Updates the Flowy project generator locally.

      $ mix local.flowy

  Accepts the same command line options as `archive.install hex flowy_new`.
  """

  @impl true
  def run(args) do
    Mix.Task.run("archive.install", ["hex", "flowy_new" | args])
  end
end
