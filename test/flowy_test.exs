defmodule FlowyTest do
  use ExUnit.Case
  doctest Flowy

  test "greets the world" do
    assert Flowy.hello() == :world
  end
end
