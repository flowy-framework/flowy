defmodule <%= inspect core.module %>Test do
  use <%= core.base_module %>.DataCase

  alias <%= inspect schema.module %>
  alias <%= inspect core.module %>
  import <%= core.base_module %>.Test.Setups

  describe "managing operations with existing data" do
    @describetag :core_<%= schema.plural %>
    setup [:setup_<%= schema.singular %>]

    test "get all <%= schema.plural %>", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert <%= inspect core.alias %>.all() == [<%= schema.singular %>]
    end

    test "get last <%= schema.singular %>", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert <%= inspect core.alias %>.last(1) == [<%= schema.singular %>]
    end

    test "get <%= schema.singular %> by id", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert <%= inspect core.alias %>.get!(<%= schema.singular %>.id) == <%= schema.singular %>
    end

    test "update <%= schema.singular %>", %{<%= schema.singular %>: <%= schema.singular %>} do
      update_attrs = <%= Mix.Phoenix.to_text schema.params.update%>

      assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect core.alias %>.update(<%= schema.singular %>, update_attrs)<%= for {field, value} <- schema.params.update do %>
      assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
    end

    test "change/1", %{<%= schema.singular %>: <%= schema.singular %>} do
      assert %Ecto.Changeset{} = <%= inspect core.alias %>.change(<%= schema.singular %>)
    end

    test "delete <%= schema.singular %>", %{<%= schema.singular %>: %{id: <%= schema.singular %>_id} = <%= schema.singular %>} do
      assert {:ok, %<%= inspect schema.alias %>{id: ^<%= schema.singular %>_id}} = <%= inspect core.alias %>.delete(<%= schema.singular %>)
      assert <%= inspect core.alias %>.get(<%= schema.singular %>_id) == nil
    end

    test "delete all <%= schema.plural %>" do
      assert <%= inspect core.alias %>.delete_all() == {1, nil}
      assert <%= inspect core.alias %>.all() == []
    end
  end

  @tag :core_<%= schema.plural %>
  test "create <%= schema.singular %>" do
    valid_attrs = <%= Mix.Phoenix.to_text schema.params.create %>

    assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect core.alias %>.create(valid_attrs)<%= for {field, value} <- schema.params.create do %>
    assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
  end
end
