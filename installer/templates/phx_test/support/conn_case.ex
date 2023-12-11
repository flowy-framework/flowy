defmodule <%= @web_namespace %>.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use <%= @web_namespace %>.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint <%= @endpoint_module %>

      use <%= @web_namespace %>, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import <%= @web_namespace %>.ConnCase
    end
  end<%= if @ecto do %>

  setup tags do
    <%= @app_module %>.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end<% else %>

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end<% end %>

  def setup_auth_header(%{conn: conn}) do
    %{
      conn:
        conn
        |> Plug.Conn.put_req_header(conn, "accept", "application/json")
        |> Plug.Conn.put_req_header("authorization", "Bearer #{Flowy.Utils.JwtToken.sign!()}")
    }
  end

  def delete_auth_header(%{conn: conn}) do
    %{
      conn:
        conn
        |> Plug.Conn.delete_req_header("authorization")
    }
  end
end
