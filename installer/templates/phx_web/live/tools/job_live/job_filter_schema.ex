defmodule <%= @web_namespace %>.Tools.JobLive.JobFilterSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @workers ~w[]
  @states Oban.Job.states()

  embedded_schema do
    field :worker, :string
    field :state, :string
    field :queue, :string
  end

  @optional_field [:worker, :state, :queue]

  def changeset(schema, params) do
    schema
    |> cast(params, @optional_field)
  end

  def workers, do: @workers |> Enum.sort()
  def states, do: @states |> Enum.sort()
  def queues, do: Keyword.keys(Oban.config().queues) |> Enum.sort()
end
