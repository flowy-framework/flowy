defmodule Flowy.Utils.CaseTest do
  use ExUnit.Case, async: true

  alias Flowy.Utils.Case

  alias Flowy.{
    MyStruct,
    MyStructDerived,
    MyStructDerivedWithOnly,
    MyStructDerivedWithExcept,
    MySerializableStruct
  }

  describe "to_camel_case/1" do
    test "struct" do
      my_struct = %MyStruct{cool_key: "value"}

      assert Case.to_camel_case(my_struct) == my_struct
    end

    test "seriazable struct" do
      my_struct = %MySerializableStruct{cool_key: "value"}

      assert Case.to_camel_case(my_struct) == %{"coolKey" => "value"}
    end

    test "derived struct" do
      my_struct = %MyStructDerived{cool_key: "value", another_key: "another"}

      assert Case.to_camel_case(my_struct) == %{"coolKey" => "value", "anotherKey" => "another"}
    end

    test "derived struct with only" do
      my_struct = %MyStructDerivedWithOnly{cool_key: "value", another_key: "another"}

      assert Case.to_camel_case(my_struct) == %{"coolKey" => "value"}
    end

    test "derived struct with except" do
      my_struct = %MyStructDerivedWithExcept{cool_key: "value", another_key: "another"}

      assert Case.to_camel_case(my_struct) == %{"anotherKey" => "another"}
    end
  end

  describe "to_snake_case/1" do
    test "struct" do
      my_struct = %MyStruct{cool_key: "value"}

      assert Case.to_snake_case(my_struct) == my_struct
    end
  end
end
