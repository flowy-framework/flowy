defmodule Flowy.Utils.KeysConverter do
  def to_string(map) do
    for {key, val} <- map, into: %{}, do: {convert_to_string(key), val}
  end

  def to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {convert_to_atom(key), val}
  end

  defp convert_to_string(value) when is_binary(value), do: value
  defp convert_to_string(value) when is_atom(value), do: Atom.to_string(value)

  defp convert_to_atom(value) when is_binary(value), do: String.to_atom(value)
  defp convert_to_atom(value) when is_atom(value), do: value
end
