defprotocol Flowy.Utils.Case.Serializable do
  @moduledoc """
  Protocol controlling how a value is serialized. It is useful to handle custom
  structs of your app, without that the `Flowy.Utils.Case` will be skipped and passed directly to Jason.

  ## Deriving

  The protocol allows leveraging the Elixir's `@derive` feature
  to simplify protocol implementation in trivial cases. Accepted
  options are:

    * `:only` - encodes only values of specified keys.
    * `:except` - encodes all struct fields except specified keys.

  By default all keys except the `:__struct__` key are serialized.

  It also returns a compile time dict of the camelized keys in order
  to increase the speed of the case conversion.

  ## Example

  Let's assume a presence of the following struct:

      defmodule Test do
        defstruct [:foo, :bar, :baz]
      end

  If we were to call `@derive Flowy.Utils.Case.Serializable` just before `defstruct`,
  an implementation similar to the following implementation would be generated:

      defimpl Flowy.Utils.Case.Serializable, for: Test do
        def serialize(data) do
          {Map.take(data, [:foo, :bar, :baz]), %{foo: "foo", bar: "bar", baz: "baz"}}
        end
      end

  If we called `@derive {Flowy.Utils.Case.Serializable, only: [:foo]}`, an implementation
  similar to the following implementation would be generated:

      defimpl Flowy.Utils.Case.Serializable, for: Test do
        def serialize(data) do
          {Map.take(data, [:foo]), %{foo: "foo"}}
        end
      end

  If we called `@derive {Flowy.Utils.Case.Serializable, except: [:foo]}`, an implementation
  similar to the following implementation would be generated:

      defimpl Flowy.Utils.Case.Serializable, for: Test do
        def serialize(data) do
          {Map.take(data, [:bar, :baz]), %{bar: "bar", baz: "baz"}}
        end
      end

  """

  @fallback_to_any true
  @doc false
  @spec serialize(data :: any()) :: any() | {any(), camelized_dict :: map()}
  def serialize(data)
end

defimpl Flowy.Utils.Case.Serializable, for: Any do
  defmacro __deriving__(module, struct, options) do
    fields = fields_to_encode(struct, options)

    camelized_dict =
      fields
      |> Enum.map(fn field -> {field, field |> to_string() |> Recase.to_camel()} end)
      |> Map.new()

    quote do
      defimpl Flowy.Utils.Case.Serializable, for: unquote(module) do
        def serialize(data) do
          {Map.take(data, unquote(fields)), unquote(Macro.escape(camelized_dict))}
        end
      end
    end
  end

  @spec serialize(any()) :: any()
  def serialize(data), do: data

  defp fields_to_encode(struct, opts) do
    cond do
      only = Keyword.get(opts, :only) ->
        only

      except = Keyword.get(opts, :except) ->
        Map.keys(struct) -- [:__struct__ | except]

      true ->
        Map.keys(struct) -- [:__struct__]
    end
  end
end
