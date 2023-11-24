defmodule <%= inspect schema.module %>Test do
  use ExUnit.Case

  alias <%= inspect schema.module %>

  @invalid_attrs <%= Mix.Phoenix.to_text for {key, _} <- schema.params.create, into: %{}, do: {key, nil} %>
  @valid_attrs <%= Mix.Flowy.to_text schema.params.create %>

  @tag :schema_<%= schema.singular %>
  test "<%= schema.human_singular %> schema metadata" do
    assert <%= inspect schema.alias %>.__schema__(:source) == "<%= schema.table %>"
    assert <%= inspect schema.alias %>.__schema__(:primary_key) == [:id]

    assert <%= inspect schema.alias %>.all_fields() == <%= inspect Mix.Flowy.Schema.all_fields(schema) %>
  end

  describe "changeset/2" do
    @describetag :schema_<%= schema.singular %>
    test "with valid params" do
      changeset = <%= inspect schema.alias %>.changeset(%<%= inspect schema.alias %>{}, @valid_attrs)
      assert changeset.required == <%= inspect Mix.Flowy.Schema.required_keys(schema) %>
      assert changeset.valid?
    end

    test "with invalid params" do
      changeset = <%= inspect schema.alias %>.changeset(%<%= inspect schema.alias %>{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
