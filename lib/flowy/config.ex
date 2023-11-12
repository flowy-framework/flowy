defmodule Flowy.Config do
  @moduledoc """
  This module defines a struct that contains all of the fields necessary to configure
  an instance of Flowy.
  """
  alias Flowy.Config.Service

  @type t :: %__MODULE__{
          service: Service.t()
        }

  defstruct [
    :service
  ]

  @doc """
  Builds a Flowy configuration struct with the given options.
  """
  @spec build(map()) :: t()
  def build(opts) do
    %__MODULE__{
      service: service(Keyword.get(opts, :service, []))
    }
  end

  defp service([]) do
    %Service{
      keys_format: :snake_case,
      codes: [
        "403": %{
          code: "002",
          description: "Forbidden: Something doesn't look quite right. Double check it, will you?"
        }
      ]
    }
  end
end
