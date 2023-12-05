defmodule <%= @web_namespace %>.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, Paths, Server, Schema, MediaType, Response}
  alias <%= @web_namespace %>.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "<%= @web_namespace %> API",
        version: "1.0"
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router),
      components: %Components{
        responses: %{
          unprocessable_entity: %Response{
            description: "Unprocessable Entity",
            content: %{"application/json" => %MediaType{schema: %Schema{type: :object}}}
          }
        }
      }
    }
    # Discover request/response schemas from path specs
    |> OpenApiSpex.resolve_schema_modules()
  end
end
