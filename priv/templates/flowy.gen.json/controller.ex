defmodule <%= inspect core.web_module %>.<%= inspect Module.concat([schema.web_namespace, "Controllers", "Api", schema.alias]) %>Controller do
  use <%= inspect core.web_module %>, :controller
  use OpenApiSpex.ControllerSpecs
  alias OpenApiSpex.{Schema, Reference}

  alias <%= inspect core.web_module %>.ApiSpecs.<%= inspect core.alias %>.{
    <%= inspect schema.alias %>Params,
    <%= inspect schema.alias %>Response,
    <%= inspect core.alias %>Response,
    <%= inspect schema.alias %>Request
  }

  alias <%= inspect core.module %>
  alias <%= inspect schema.module %>

  action_fallback Flowy.Web.Controllers.FallbackController

  tags ["<%= schema.plural %>"]

  operation :index,
  summary: "List <%= schema.plural %>",
  description: "List all <%= schema.plural %>",
  responses: [
    ok: {"<%= inspect schema.alias %> List Response", "application/json", <%= inspect core.alias %>Response},
    unprocessable_entity: %Reference{"$ref": "#/components/responses/unprocessable_entity"}
  ]

  def index(conn, _params) do
    <%= schema.plural %> = <%= inspect core.alias %>.all()
    render(conn, :index, <%= schema.plural %>: <%= schema.plural %>)
  end

  operation :create,
    summary: "Create <%= schema.singular %>",
    description: "Create a <%= schema.singular %>",
    parameters: [],
    request_body: {"The <%= schema.singular %> attributes", "application/json", <%= inspect schema.alias %>Request, required: true},
    responses: [
      created: {"<%= inspect schema.alias %>", "application/json", <%= inspect schema.alias %>Response}
    ]

  def create(conn, %{<%= inspect schema.singular %> => <%= schema.singular %>_params}) do
    with {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} <- <%= inspect core.alias %>.create(<%= schema.singular %>_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"<%= schema.api_route_prefix %>/#{<%= schema.singular %>}")
      |> render(:show, <%= schema.singular %>: <%= schema.singular %>)
    end
  end

  operation :show,
    summary: "Show <%= schema.singular %>.",
    description: "Show a <%= schema.singular %> by ID.",
    parameters: [
      id: [
        in: :path,
        # `:type` can be an atom, %Schema{}, or %Reference{}
        type: %Schema{type: :string, format: :uuid},
        description: "<%= inspect schema.alias %> ID",
        example: "1d8c5e23-fe39-4889-bc41-a4d7bc966c2d",
        required: true
      ]
    ],
    responses: [
      ok: {"<%= inspect schema.alias %>", "application/json", <%= inspect schema.alias %>Response}
    ]

  def show(conn, %{"id" => id}) do
    <%= schema.singular %> = <%= inspect core.alias %>.get!(id)
    render(conn, :show, <%= schema.singular %>: <%= schema.singular %>)
  end

  operation :update,
    summary: "Update <%= schema.singular %>",
    parameters: [
      id: [
        in: :path,
        description: "<%= inspect schema.alias %> ID",
        type: :string,
        example: "4ce44b1a-d4b7-4fcf-a383-1a585717c8d1"
      ]
    ],
    request_body: {"<%= inspect schema.alias %> params", "application/json", <%= inspect schema.alias %>Params},
    responses: [
      ok: {"<%= inspect schema.alias %> response", "application/json", <%= inspect schema.alias %>Response}
    ]

  def update(conn, %{"id" => id, <%= inspect schema.singular %> => <%= schema.singular %>_params}) do
    <%= schema.singular %> = <%= inspect core.alias %>.get!(id)

    with {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} <- <%= inspect core.alias %>.update(<%= schema.singular %>, <%= schema.singular %>_params) do
      render(conn, :show, <%= schema.singular %>: <%= schema.singular %>)
    end
  end

  operation :delete,
    summary: "Delete an <%= schema.singular %>",
    description: "Delete an <%= schema.singular %>",
    parameters: [
      id: [
        in: :path,
        # `:type` can be an atom, %Schema{}, or %Reference{}
        type: %Schema{type: :string, format: :uuid},
        description: "<%= inspect schema.alias %> ID",
        example: "1d8c5e23-fe39-4889-bc41-a4d7bc966c2d",
        required: true
      ]
    ],
    responses: [
      ok: {"<%= inspect schema.alias %> List Response", "application/json", <%= inspect core.alias %>Response},
      unprocessable_entity: %Reference{"$ref": "#/components/responses/unprocessable_entity"}
    ]

  def delete(conn, %{"id" => id}) do
    <%= schema.singular %> = <%= inspect core.alias %>.get!(id)

    with {:ok, %<%= inspect schema.alias %>{}} <- <%= inspect core.alias %>.delete(<%= schema.singular %>) do
      send_resp(conn, :no_content, "")
    end
  end
end
