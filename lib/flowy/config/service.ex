defmodule Flowy.Config.Service do
  @moduledoc """
  This module defines a struct that contains all of available fields
  to configure the web part of Flowy.
  """
  @type t :: %__MODULE__{
          keys_format: String.t(),
          codes: [map()]
        }

  defstruct [
    :keys_format,
    :codes
  ]

  @doc """
  Find an http code in the list of codes.
  """
  @spec find_code(Flowy.Config.Service.t(), String.t()) :: any() | {:error, :code_not_found}
  def find_code(%__MODULE__{codes: codes}, code) do
    codes[code] || {:error, :code_not_found}
  end
end
