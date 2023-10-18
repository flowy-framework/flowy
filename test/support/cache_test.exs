defmodule Flowy.Support.CacheTest do
  use ExUnit.Case
  alias Flowy.Support.{Cache, Cache.MemoryStore}

  describe "read/1" do
    @describetag :memory_store
    setup do
      start_supervised(MemoryStore)
      Cache.write(:foo, "bar")

      :ok
    end

    test "returns :ok with value when key exists and has not expired" do
      assert {:ok, "bar"} = Cache.read(:foo)
    end

    test "returns :error when key does not exist" do
      assert {:error, :not_found} = Cache.read(:non_existent_key)
    end

    test "returns :error when key does not exist and we pass the module" do
      assert {:error, :not_found} = Cache.read(MemoryStore, :non_existent_key, [])
    end

    @tag :memory_store_get_expired
    test "returns :error when key has expired" do
      # wait for the default TTL of 5 minutes to expire
      :timer.sleep(2000)
      assert {:error, :expired} = Cache.read(:foo, ttl: 1)
    end
  end

  describe "write/2" do
    @describetag :memory_store
    setup do
      start_supervised(MemoryStore)
      :ok
    end

    test "returns :ok with value when inserting a new key-value pair" do
      assert {:ok, "bar"} = Cache.write(:foo, "bar")
      assert {:ok, "baz"} = Cache.write(:qux, "baz")
    end

    test "returns :ok with updated value when updating an existing key" do
      assert {:ok, "bar"} = Cache.write(:foo, "bar")
      assert {:ok, "qux"} = Cache.write(:foo, "qux")
    end

    test "returns :ok with updated value when updating an existing key and pass the module" do
      assert {:ok, "bar"} = Cache.write(MemoryStore, :foo, "bar")
      assert {:ok, "qux"} = Cache.write(MemoryStore, :foo, "qux")
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
      assert {:ok, "bar"} = Cache.fetch(:foo, fn -> "bar" end)
      assert {:ok, "bar"} = Cache.read(:foo)
    end

    test "returns :ok with new value when key does not exist" do
      assert {:ok, "bar"} = Cache.fetch(:foo, fn -> "bar" end)
    end

    test "returns :ok with new value when key does not exist and pass the module" do
      assert {:ok, "bar"} = Cache.fetch(MemoryStore, :foo, fn -> "bar" end, [])
    end

    test "returns :ok with new value when key does not exist and pass the module as opts" do
      assert {:ok, "bar"} = Cache.fetch(:foo, fn -> "bar" end, store: MemoryStore)
    end

    @tag :memory_store_fetch
    test "returns :ok with updated value when key has expired" do
      assert {:ok, "bar"} = Cache.fetch(:foo, fn -> "bar" end)
      # wait for the default TTL of 5 minutes to expire
      :timer.sleep(2000)

      assert {:ok, "qux"} = Cache.fetch(:foo, fn -> "qux" end, ttl: 1)
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
      {:ok, _value} = Cache.write(key, value)
      assert {:ok, :deleted} == Cache.delete(key)
      assert {:error, :not_found} == Cache.read(key)
    end

    test "delete a value passing a module" do
      key = :test_key
      value = "test_value"
      {:ok, _value} = Cache.write(MemoryStore, key, value)
      assert {:ok, :deleted} == Cache.delete(MemoryStore, key)
      assert {:error, :not_found} == Cache.read(key, store: MemoryStore)
    end

    test "delete a non-existing value" do
      assert {:error, :not_found} == Cache.delete(:non_existing_key)
    end
  end

  test "store/0" do
    assert Cache.store() == MemoryStore
  end
end
