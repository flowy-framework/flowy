defmodule <%= inspect core.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>LiveTest do
  use <%= inspect core.web_module %>.ConnCase

  import Phoenix.LiveViewTest
  import <%= core.base_module %>.Test.Setups

  @create_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.create, into: %{}, do: {key, Mix.Phoenix.Schema.live_form_value(value)} %>
  @update_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.update, into: %{}, do: {key, Mix.Phoenix.Schema.live_form_value(value)} %>
  @invalid_attrs <%= Mix.Phoenix.to_text for {key, value} <- schema.params.create, into: %{}, do: {key, value |> Mix.Phoenix.Schema.live_form_value() |> Mix.Phoenix.Schema.invalid_form_value()} %>

  describe "Index" do
    setup [:setup_<%= schema.singular %>]

    test "lists all <%= schema.plural %>", <%= if schema.string_attr do %>%{conn: conn, <%= schema.singular %>: <%= schema.singular %>}<% else %>%{conn: conn}<% end %> do
      {:ok, _index_live, html} = live(conn, ~p"<%= schema.route_prefix %>")

      assert html =~ "<%= schema.human_plural %>"<%= if schema.string_attr do %>
      assert html =~ <%= schema.singular %>.<%= schema.string_attr %><% end %>
    end

    test "saves new <%= schema.singular %>", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"<%= schema.route_prefix %>")

      assert index_live |> element(~s{a[href="<%= schema.route_prefix %>/new"]}) |> render_click() =~
               "New <%= schema.human_singular %>"

      assert_patch(index_live, ~p"<%= schema.route_prefix %>/new")

      assert index_live
             |> form("#<%= schema.singular %>-form", <%= schema.singular %>: @invalid_attrs)
             |> render_change() =~ "<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>"

      assert index_live
             |> form("#<%= schema.singular %>-form", <%= schema.singular %>: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"<%= schema.route_prefix %>")

      html = render(index_live)
      assert html =~ "<%= schema.human_singular %> created successfully"<%= if schema.string_attr do %>
      assert html =~ "some <%= schema.string_attr %>"<% end %>
    end

    test "updates <%= schema.singular %> in listing", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      {:ok, index_live, _html} = live(conn, ~p"<%= schema.route_prefix %>")

      assert index_live |> element(~s{#<%= schema.collection %>-#{<%= schema.singular %>.id} a[href="<%= schema.route_prefix %>/#{<%= schema.singular %>.id}/edit"]}) |> render_click() =~
               "Edit <%= schema.human_singular %>"

      assert_patch(index_live, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}/edit")

      assert index_live
             |> form("#<%= schema.singular %>-form", <%= schema.singular %>: @invalid_attrs)
             |> render_change() =~ "<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>"

      assert index_live
             |> form("#<%= schema.singular %>-form", <%= schema.singular %>: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"<%= schema.route_prefix %>")

      html = render(index_live)
      assert html =~ "<%= schema.human_singular %> updated successfully"<%= if schema.string_attr do %>
      assert html =~ "some updated <%= schema.string_attr %>"<% end %>
    end

    test "deletes <%= schema.singular %> in listing", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      {:ok, index_live, _html} = live(conn, ~p"<%= schema.route_prefix %>")

      assert index_live |> element(~s{#<%= schema.collection %>-#{<%= schema.singular %>.id} a[href="<%= schema.route_prefix %>/#{<%= schema.singular %>.id}/delete"]}) |> render_click() =~
      "Delete <%= schema.human_singular %>"
    end
  end

  describe "Show" do
    setup [:setup_<%= schema.singular %>]

    test "displays <%= schema.singular %>", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      {:ok, _show_live, html} = live(conn, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")

      assert html =~ "Overview"<%= if schema.string_attr do %>
      assert html =~ <%= schema.singular %>.<%= schema.string_attr %><% end %>
    end

    test "updates <%= schema.singular %> within modal", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      {:ok, show_live, _html} = live(conn, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")

      assert show_live |> element(~s{a[href="<%= schema.route_prefix %>/#{<%= schema.singular %>.id}/show/edit"]}) |> render_click() =~
               "Edit <%= schema.human_singular %>"

      assert_patch(show_live, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}/show/edit")

      assert show_live
             |> form("#<%= schema.singular %>-form", <%= schema.singular %>: @invalid_attrs)
             |> render_change() =~ "<%= Mix.Phoenix.Schema.failed_render_change_message(schema) %>"

      assert show_live
             |> form("#<%= schema.singular %>-form", <%= schema.singular %>: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"<%= schema.route_prefix %>/#{<%= schema.singular %>}")

      html = render(show_live)
      assert html =~ "<%= schema.human_singular %> updated successfully"<%= if schema.string_attr do %>
      assert html =~ "some updated <%= schema.string_attr %>"<% end %>
    end
  end
end
