defmodule Mix.Tasks.Flowy.Gen.Schema do
  @shortdoc "Generates a Schema module"

  @moduledoc """
  Generates Flowy components.

      $ mix flowy.gen.query User users name:string age:integer
  """

  use Mix.Task

  def build(args, parent_opts, help \\ __MODULE__) do
    args =
      args
      |> complete_args()

    Mix.Tasks.Phx.Gen.Schema.build(args, parent_opts, help)
  end

  @doc false
  def run(args) do
    args =
      args
      |> complete_args()

    Mix.Tasks.Phx.Gen.Schema.run(args)
  end

  defp complete_args([first | rest]) do
    ["Schemas.#{first}"] ++ rest
  end
end
