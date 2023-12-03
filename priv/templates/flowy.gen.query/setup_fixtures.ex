defmodule <%= query.base_module %>.Test.Setups do
  @moduledoc false
  defp add_to_context(context, attrs) do
    context
    |> Enum.into(attrs)
  end
end
