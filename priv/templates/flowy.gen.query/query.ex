defmodule <%= inspect query.module %> do
  @moduledoc """
  This module contains the queries for <%= schema.plural %> .
  """
  import Ecto.Query
  import <%= query.base_module %>.Queries.Helper

  alias <%= inspect schema.module %>
  alias <%= inspect schema.repo %>

  @doc """
  Returns the number of <%= schema.plural %>.

  ## Examples

      iex> <%= inspect query.module %>.count()
      10

  """
  def count() do
    base()
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns the list of <%= schema.plural %>.

  ## Examples

      iex> <%= inspect query.module %>.all()
      [%<%= inspect schema.alias %>{}, ...]

  """
  def all(opts \\ []) do
    base()
    |> handle_preloads(opts)
    |> Repo.all()
  end

  @doc """
  Returns the last inserted <%= schema.plural %>.

  ## Examples

      iex> <%= inspect query.module %>.last(3)
      [%<%= inspect schema.alias %>{}, ...]

  """
  def last(limit) do
    base()
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets a single <%= schema.singular %>.

  Raises if the <%= schema.human_singular %> does not exist.

  ## Examples

      iex> <%= inspect query.module  %>.get!("44bff7b0-c9e4-4d5d-a6f3-61fb2c6dbddf")
      %<%= inspect schema.alias %>{}

  """
  def get!(id, opts \\ []) do
    base()
    |> handle_preloads(opts)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single <%= schema.singular %>.

  ## Examples

      iex> <%= inspect query.module %>.get("44bff7b0-c9e4-4d5d-a6f3-61fb2c6dbddf")
      %<%= inspect schema.alias %>{}

  """
  def get(id, opts \\ []) do
    base()
    |> handle_preloads(opts)
    |> Repo.get(id)
  end

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> <%= inspect query.module %>.create(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> <%= inspect query.module %>.create(%{field: bad_value})
      {:error, ...}

  """
  def create(attrs, opts \\ []) do
    case <%= inspect schema.alias %>.changeset(%<%= inspect schema.alias %>{}, attrs) |> Repo.insert() do
      {:ok, record} -> {:ok, record |> handle_preloads(opts)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Creates a <%= schema.singular %>.

  Raise an error if the <%= schema.human_singular %> could not be created.

  ## Examples

      iex> <%= inspect query.module %>.create(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> <%= inspect query.module %>.create(%{field: bad_value})
      {:error, ...}

  """
  def create!(attrs, opts \\ []) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert!()
    |> handle_preloads(opts)
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> <%= inspect query.module %>.update(<%= schema.singular %>, %{field: new_value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> <%= inspect query.module %>.update(<%= schema.singular %>, %{field: bad_value})
      {:error, ...}

  """
  def update(model, attrs) do
    model
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a <%= schema.singular %>.

  Raise an error if the <%= schema.human_singular %> could not be updated.

  ## Examples

      iex> <%= inspect query.module %>.update!(<%= schema.singular %>, %{field: new_value})
      {:ok, %<%= inspect schema.alias %>{}}

  """
  def update!(model, attrs) do
    model
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Deletes a <%= inspect schema.alias %>.

  ## Examples

      iex> <%= inspect query.module %>.delete(<%= schema.singular %>)
      {:ok, %<%= inspect schema.alias %>{}}

  """
  def delete(model) do
    model
    |> Repo.delete()
  end

  @doc """
  Raise an error if the <%= schema.human_singular %> could not be updated.
  ## Examples

      iex> <%= inspect query.module %>.delete!(<%= schema.singular %>)
      {:ok, %<%= inspect schema.alias %>{}}

  """
  def delete!(model) do
    model
    |> Repo.delete!()
  end

  @doc """
  Returns a data structure for tracking <%= schema.singular %> changes.

  ## Examples

      iex> <%= inspect query.module %>.changeset(<%= schema.singular %>)
      %Todo{...}

  """
  def changeset(model, attrs \\ %{}) do
    model
    |> <%= inspect schema.alias %>.changeset(attrs)
  end

  @doc false
  def base,
    do:
      from(<%= schema.singular %> in <%= inspect schema.alias %>,
        as: :<%= schema.singular %>
      )
end
