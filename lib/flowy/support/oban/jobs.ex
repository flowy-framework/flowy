defmodule Flowy.Support.Oban.Jobs do
  alias Flowy.Support.Oban.Job
  import Ecto.Query

  def all() do
    base()
    |> repo().all()
  end

  def delete(model) do
    model
    |> repo().delete()
  end

  def delete_all() do
    base()
    |> repo().delete_all()
  end

  def base, do: from(Job, as: :job)

  def repo() do
    # TODO: Build a better configuration system
    Application.get_env(:flowy, :repo)
  end
end
