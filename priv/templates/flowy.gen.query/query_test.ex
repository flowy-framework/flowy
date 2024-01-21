defmodule <%= inspect query.module %>Test do
  use <%= query.base_module %>.DataCase

  alias <%= inspect schema.module %>
  alias <%= inspect query.module %>
  import <%= query.base_module %>.Test.Setups

  @invalid_attrs <%= Mix.Phoenix.to_text for {key, _} <- schema.params.create, into: %{}, do: {key, nil} %>

  describe "managing operations with existing data" do
    @describetag :<%= schema.singular %>_query
    setup [:setup_<%= schema.singular %>]

    test "get all <%= schema.singular %>s", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert <%= inspect query.alias %>.all() == [<%= schema.singular %>]
    end

    test "get last <%= schema.singular %>", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert <%= inspect query.alias %>.last(1) == [<%= schema.singular %>]
    end

    test "get <%= schema.singular %> by id", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert <%= inspect query.alias %>.get!(<%= schema.singular %>.id) == <%= schema.singular %>
    end

    test "update <%= schema.singular %>", %{<%= schema.singular %>: <%= schema.singular %>} do
      update_attrs = <%= Mix.Phoenix.to_text schema.params.update%>

      assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect query.alias %>.update(<%= schema.singular %>, update_attrs)<%= for {field, value} <- schema.params.update do %>
      assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
    end

    test "delete <%= schema.singular %>", %{<%= schema.singular %>: %{id: <%= schema.singular %>_id} = <%= schema.singular %>} do
      assert {:ok, %<%= inspect schema.alias %>{id: ^<%= schema.singular %>_id}} = <%= inspect query.alias %>.delete(<%= schema.singular %>)
      assert <%= inspect query.alias %>.get(<%= schema.singular %>_id) == nil
    end

    test "changeset/1 returns a <%= schema.singular %> changeset", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert %Ecto.Changeset{} = <%= inspect query.alias %>.changeset(<%= schema.singular %>)
    end
  end

  @tag :<%= schema.singular %>_query
  test "create <%= schema.singular %>" do
    valid_attrs = <%= Mix.Phoenix.to_text schema.params.create %>

    assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect query.alias %>.create(valid_attrs)<%= for {field, value} <- schema.params.create do %>
    assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = <%= inspect query.alias %>.create(@invalid_attrs)
  end
end
