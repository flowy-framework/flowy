defmodule Flowy.MySerializableStruct do
  defstruct [:cool_key]

  defimpl Flowy.Utils.Case.Serializable do
    def serialize(data), do: Map.take(data, [:cool_key])
  end
end

defmodule Flowy.MyStruct do
  defstruct [:cool_key]
end

defmodule Flowy.MyStructDerived do
  @derive Flowy.Utils.Case.Serializable

  defstruct [:cool_key, :another_key]
end

defmodule Flowy.MyStructDerivedWithOnly do
  @derive {Flowy.Utils.Case.Serializable, only: [:cool_key]}

  defstruct [:cool_key, :another_key]
end

defmodule Flowy.MyStructDerivedWithExcept do
  @derive {Flowy.Utils.Case.Serializable, except: [:cool_key]}

  defstruct [:cool_key, :another_key]
end
