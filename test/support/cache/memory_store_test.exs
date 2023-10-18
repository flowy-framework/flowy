defmodule Flowy.Support.Cache.MemoryStoreTest do
  use ExUnit.Case
  alias Flowy.Support.Cache.MemoryStore

  describe "read/1" do
    @describetag :memory_store
    setup do
      start_supervised(MemoryStore)
      MemoryStore.write(:foo, "bar")

      :ok
    end

    test "returns :ok with value when key exists and has not expired" do
      assert {:ok, "bar"} = MemoryStore.read(:foo)
    end

    test "returns :error when key does not exist" do
      assert {:error, :not_found} = MemoryStore.read(:non_existent_key)
    end

    @tag :memory_store_get_expired
    test "returns :error when key has expired" do
      # wait for the default TTL of 5 minutes to expire
      :timer.sleep(2000)
      assert {:error, :expired} = MemoryStore.read(:foo, ttl: 1)
    end
  end

  describe "write/2" do
    @describetag :memory_store
    setup do
      start_supervised(MemoryStore)
      :ok
    end

    test "returns :ok with value when inserting a new key-value pair" do
      assert {:ok, "bar"} = MemoryStore.write(:foo, "bar")
      assert {:ok, "baz"} = MemoryStore.write(:qux, "baz")
    end

    test "returns :ok with updated value when updating an existing key" do
      assert {:ok, "bar"} = MemoryStore.write(:foo, "bar")
      assert {:ok, "qux"} = MemoryStore.write(:foo, "qux")
    end
  end

  describe "fetch/3" do
    @describetag :memory_store
    setup do
      start_supervised(MemoryStore)
      :ok
    end

    @tag :emi
    test "returns :ok with value when key exists and has not expired" do
      assert {:ok, "bar"} = MemoryStore.fetch(:foo, fn -> "bar" end)
      assert {:ok, "bar"} = MemoryStore.read(:foo)
    end

    test "returns :ok with new value when key does not exist" do
      assert {:ok, "bar"} = MemoryStore.fetch(:foo, fn -> "bar" end)
    end

    @tag :memory_store_fetch
    test "returns :ok with updated value when key has expired" do
      assert {:ok, "bar"} = MemoryStore.fetch(:foo, fn -> "bar" end)
      # wait for the default TTL of 5 minutes to expire
      :timer.sleep(2000)

      assert {:ok, "qux"} = MemoryStore.fetch(:foo, fn -> "qux" end, ttl: 1)
    end
  end

  describe "delete/1" do
    @describetag :memory_store

    setup do
      start_supervised(MemoryStore)
      :ok
    end

    test "delete a value" do
      key = :test_key
      value = "test_value"
      {:ok, _value} = MemoryStore.write(key, value)
      assert {:ok, :deleted} == MemoryStore.delete(key)
      assert {:error, :not_found} == MemoryStore.read(key)
    end

    test "delete a non-existing value" do
      assert {:error, :not_found} == MemoryStore.delete(:non_existing_key)
    end
  end
end
