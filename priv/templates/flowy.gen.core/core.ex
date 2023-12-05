defmodule <%= inspect core.module %> do
  @moduledoc """
  This module contains the business logic for <%= schema.human_plural %>.
  """

  alias <%= core.base_module %>.Queries.<%= inspect schema.alias %>Query

  defdelegate all, to: <%= inspect schema.alias %>Query
  defdelegate get(id), to: <%= inspect schema.alias %>Query
  defdelegate last(limit), to: <%= inspect schema.alias %>Query
  defdelegate get!(id), to: <%= inspect schema.alias %>Query
  defdelegate update!(model, attrs), to: <%= inspect schema.alias %>Query
  defdelegate update(model, attrs), to: <%= inspect schema.alias %>Query
  defdelegate delete(model), to: <%= inspect schema.alias %>Query
  defdelegate create(attrs), to: <%= inspect schema.alias %>Query
  defdelegate change(model, attrs \\ %{}), to: <%= inspect schema.alias %>Query, as: :changeset
end
