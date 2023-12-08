defmodule <%= inspect core.web_module %>.ApiSpecs.<%= inspect core.alias %> do
  alias OpenApiSpex.Schema

  defmodule <%= inspect schema.alias %> do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "<%= schema.alias %>",
      description: "An <%= schema.singular %> of the app",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "<%= inspect schema.alias %> ID", format: :uuid},
        insertedAt: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updatedAt: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
      },
      required: [],
      example: %{
        "id" => "adb637cf-23b1-45b1-bf11-5bca5cc41a0c",
        "insertedAt" => "2017-09-12T12:34:55Z",
        "updatedAt" => "2017-09-13T10:11:12Z"
      }
    })
  end

  defmodule <%= inspect schema.alias %>Params do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "<%= inspect schema.alias %>Params",
      description: "Attributes to update an <%= schema.singular %>",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Replace with your module properties",
          pattern: ~r/[a-zA-Z][a-zA-Z0-9_]+/
        }
      },
      example: %{
        "name" => "Replace me"
      }
    })
  end

  defmodule <%= inspect schema.alias %>Request do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "<%= schema.alias %>Request",
      description: "POST body for creating an <%= schema.singular %>",
      type: :object,
      properties: %{
        <%= schema.singular %>: %Schema{anyOf: [<%= inspect schema.alias %>]}
      },
      required: [:<%= schema.singular %>],
      example: %{
        "name" => "Joe Doe"
      }
    })
  end

  defmodule <%= inspect core.alias %>Response do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "<%= core.alias %>Response",
      description: "Response schema for multiple <%= schema.plural %>",
      type: :object,
      properties: %{
        data: %Schema{description: "The <%= schema.plural %> details", type: :array, items: <%= inspect schema.alias %>}
      },
      example: %{
        "data" => [
          %{
            "id" => "c7c3a77d-a540-436b-ae6c-3f06fbbd879e"
          },
          %{
            "id" => "fdccbe37-061a-42a7-a0f6-7a38791081af"
          }
        ]
      }
    })
  end

  defmodule <%= inspect schema.alias %>Response do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "<%= schema.alias %>Response",
      description: "Response schema for single <%= schema.singular %>",
      type: :object,
      properties: %{
        data: <%= inspect schema.alias %>
      },
      example: %{
        "id" => "adb637cf-23b1-45b1-bf11-5bca5cc41a0c",
        "insertedAt" => "2017-09-12T12:34:55Z",
        "updatedAt" => "2017-09-13T10:11:12Z"
      }
    })
  end
end
