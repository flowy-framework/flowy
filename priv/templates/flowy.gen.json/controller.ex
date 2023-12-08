defmodule <%= inspect core.web_module %>.<%= inspect Module.concat([schema.web_namespace, "Controllers", "Api", schema.alias]) %>Controller do
  use <%= inspect core.web_module %>, :controller

  alias <%= inspect core.module %>
  alias <%= inspect schema.module %>

  action_fallback Flowy.Web.Controllers.FallbackController

  def index(conn, _params) do
    <%= schema.plural %> = <%= inspect core.alias %>.all()
    render(conn, :index, <%= schema.plural %>: <%= schema.plural %>)
  end

  def create(conn, %{<%= inspect schema.singular %> => <%= schema.singular %>_params}) do
    with {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} <- <%= inspect core.alias %>.create(<%= schema.singular %>_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"<%= schema.api_route_prefix %>/#{<%= schema.singular %>}")
      |> render(:show, <%= schema.singular %>: <%= schema.singular %>)
    end
  end

  def show(conn, %{"id" => id}) do
    <%= schema.singular %> = <%= inspect core.alias %>.get!(id)
    render(conn, :show, <%= schema.singular %>: <%= schema.singular %>)
  end

  def update(conn, %{"id" => id, <%= inspect schema.singular %> => <%= schema.singular %>_params}) do
    <%= schema.singular %> = <%= inspect core.alias %>.get!(id)

    with {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} <- <%= inspect core.alias %>.update(<%= schema.singular %>, <%= schema.singular %>_params) do
      render(conn, :show, <%= schema.singular %>: <%= schema.singular %>)
    end
  end

  def delete(conn, %{"id" => id}) do
    <%= schema.singular %> = <%= inspect core.alias %>.get!(id)

    with {:ok, %<%= inspect schema.alias %>{}} <- <%= inspect core.alias %>.delete(<%= schema.singular %>) do
      send_resp(conn, :no_content, "")
    end
  end
end
