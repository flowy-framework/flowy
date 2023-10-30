defmodule <%= inspect core.module %> do
  alias <%= core.base_module %>.Queries.<%= inspect schema.alias %>Query

  defdelegate all, to: <%= schema.human_singular %>Query
  defdelegate get(id), to: <%= schema.human_singular %>Query
  defdelegate last(limit), to: <%= schema.human_singular %>Query
  defdelegate get!(id), to: <%= schema.human_singular %>Query
  defdelegate update!(mode, attrs), to: <%= schema.human_singular %>Query
  defdelegate update(mode, attrs), to: <%= schema.human_singular %>Query
  defdelegate delete(mode), to: <%= schema.human_singular %>Query
  defdelegate delete_all(), to: <%= schema.human_singular %>Query
  defdelegate create(attrs), to: <%= schema.human_singular %>Query
  defdelegate change(model, attrs \\ %{}), to: <%= schema.human_singular %>Query, as: :changeset
end
