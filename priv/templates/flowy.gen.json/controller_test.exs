defmodule <%= inspect core.web_module %>.<%= inspect Module.concat([schema.web_namespace, "Controllers", "Api", schema.alias]) %>ControllerTest do
  use <%= inspect core.web_module %>.ConnCase

  import <%= core.base_module %>.Tests.Fixtures.<%= inspect schema.alias %>Fixtures

  alias <%= inspect schema.module %>

  @create_attrs %{
<%= schema.params.create |> Enum.map(fn {key, val} -> "    #{key}: #{inspect(val)}" end) |> Enum.join(",\n") %>
  }
  @update_attrs %{
<%= schema.params.update |> Enum.map(fn {key, val} -> "    #{key}: #{inspect(val)}" end) |> Enum.join(",\n") %>
  }
  @invalid_attrs <%= Mix.Phoenix.to_text for {key, _} <- schema.params.create, into: %{}, do: {key, nil} %>

  setup [:setup_auth_header]

  describe "index" do
    test "lists all <%= schema.plural %>", %{conn: conn} do
      conn = get(conn, ~p"<%= schema.api_route_prefix %>")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "index with no authorization" do
    setup [:delete_auth_header]

    test "fail to lists all vendors", %{conn: conn} do
      conn = get(conn, ~p"<%= schema.api_route_prefix %>")
      assert json_response(conn, 403)
    end
  end

  describe "create <%= schema.singular %>" do
    test "renders <%= schema.singular %> when data is valid", %{conn: conn} do
      conn = post(conn, ~p"<%= schema.api_route_prefix %>", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, ~p"<%= schema.api_route_prefix %>/#{id}")

      assert %{
               "id" => ^id<%= for {key, val} <- schema.params.create |> Phoenix.json_library().encode!() |> Phoenix.json_library().decode!() do %>,
               "<%= key %>" => <%= inspect(val) %><% end %>
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"<%= schema.api_route_prefix %>", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "renders <%= schema.singular %> when data is valid", %{conn: conn, <%= schema.singular %>: %<%= inspect schema.alias %>{id: id} = <%= schema.singular %>} do
      conn = put(conn, ~p"<%= schema.api_route_prefix %>/#{<%= schema.singular %>}", @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, ~p"<%= schema.api_route_prefix %>/#{id}")

      assert %{
               "id" => ^id<%= for {key, val} <- schema.params.update |> Phoenix.json_library().encode!() |> Phoenix.json_library().decode!() do %>,
               "<%= key %>" => <%= inspect(val) %><% end %>
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn = put(conn, ~p"<%= schema.api_route_prefix %>/#{<%= schema.singular %>}", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "deletes chosen <%= schema.singular %>", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn = delete(conn, ~p"<%= schema.api_route_prefix %>/#{<%= schema.singular %>}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"<%= schema.api_route_prefix %>/#{<%= schema.singular %>}")
      end
    end
  end

  defp create_<%= schema.singular %>(_) do
    <%= schema.singular %> = <%= schema.singular %>_fixture()
    %{<%= schema.singular %>: <%= schema.singular %>}
  end
end
