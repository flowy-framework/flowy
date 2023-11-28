defmodule <%= inspect schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset
<%= if schema.prefix do %>
  @schema_prefix :<%= schema.prefix %><% end %><%= if schema.binary_id do %>
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id<% end %>
  @derive {Phoenix.Param, key: :id}
  schema <%= inspect schema.table %> do
<%= Mix.Flowy.Schema.format_fields_for_schema(schema) %>
<%= for {_, k, _, _} <- schema.assocs do %>    field <%= inspect k %>, <%= if schema.binary_id do %>:binary_id<% else %>:id<% end %>
<% end %>
    timestamps(<%= if schema.timestamp_type != :naive_datetime, do: "type: #{inspect schema.timestamp_type}" %>)
  end

  @required_fields [<%= Enum.map_join(Mix.Flowy.Schema.required_fields(schema), ", ", &inspect(elem(&1, 0))) %>]
  @optional_fields <%= inspect schema.optionals %>

  @doc """
  Returns all fields of the schema.
  """
  @spec all_fields() :: any()
  def all_fields() do
    __MODULE__.__schema__(:fields) |> Enum.sort()
  end

  @doc false
  def changeset(<%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
<%= for k <- schema.uniques do %>    |> unique_constraint(<%= inspect k %>)
<% end %>  end
end
