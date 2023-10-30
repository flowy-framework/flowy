defmodule <%= query.base_module %>.Test.Setups do
  defp add_to_context(context, attrs) do
    context
    |> Enum.into(attrs)
  end
end
