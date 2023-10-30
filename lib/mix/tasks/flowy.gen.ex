defmodule Mix.Tasks.Flowy.Gen do
  use Mix.Task

  @shortdoc "Lists all available Flowy generators"

  @moduledoc """
  Lists all available Flowy generators.

  ## CRUD related generators

  The table below shows a summary of the contents created by the CRUD generators:

  | Task | Schema | Migration | Core | Controller API | LiveView |
  |:------------------ |:-:|:-:|:-:|:-:|:-:|:-:|
  | `flowy.gen.core`   |   |   |   |   |   |   |
  """

  @doc false
  @spec run(args :: Keyword.t()) :: :ok
  def run(_args) do
    Mix.Task.run("help", ["--search", "flowy.gen."])
  end
end
