defmodule Flowy.Utils.Case.CamelCaseEncoder do
  @moduledoc """
  Format encoder for phoenix. Converts all the keys of the json data to camel case.

  ## Usage

  Add `Flowy.Utils.Case.CamelCaseEncoder` as json format encoder for phoenix:

  ```
  # config.exs
  config :phoenix, :format_encoders, json: Flowy.Utils.Case.CamelCaseEncoder
  ```

  Now all outcoming json response bodies will be converted to camel case.

  ## Structs

  If you want to control how the keys will be serilized before being encoded by `Jason`,
  you can provide a implementation for the `Flowy.Utils.Case.Serializable` protocol, by default it
  will return the structs as they come, without any transformation.

  """

  @doc """
  Encode the data to camel case and then encode it to iodata using `Jason.encode_to_iodata!/1`.
  """
  @spec encode_to_iodata!(data :: term()) :: iodata() | no_return()
  def encode_to_iodata!(data) do
    data
    |> Flowy.Utils.Case.to_camel_case()
    |> Jason.encode_to_iodata!()
  end
end
