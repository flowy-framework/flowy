defmodule Mix.Tasks.Flowy.New.Web do
  @moduledoc """
  Creates a new Flowy web project within an umbrella project.

  It expects the name of the OTP app as the first argument and
  for the command to be run inside your umbrella application's
  apps directory:

      $ cd my_umbrella/apps
      $ mix flowy.new.web APP [--module MODULE] [--app APP]

  This task is intended to create a bare Flowy project without
  database integration, which interfaces with your greater
  umbrella application(s).

  ## Examples

      $ mix flowy.new.web hello_web

  Is equivalent to:

      $ mix flowy.new.web hello_web --module HelloWeb

  Supports the same options as the `flowy.new` task.
  See `Mix.Tasks.Flowy.New` for details.
  """

  @shortdoc "Creates a new Flowy web project within an umbrella project"

  use Mix.Task

  @impl true
  def run([]) do
    Mix.Tasks.Help.run(["flowy.new.web"])
  end

  def run([path | _] = args) do
    unless Flowy.New.Generator.in_umbrella?(path) do
      Mix.raise "The web task can only be run within an umbrella's apps directory"
    end

    Mix.Tasks.Flowy.New.run(args, Flowy.New.Web, :web_path)
  end
end
