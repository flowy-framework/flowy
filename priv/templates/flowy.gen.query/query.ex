defmodule <%= inspect query.module %> do
  @moduledoc """
  This module contains the queries for <%= schema.plural %> .
  """
  import Ecto.Query

  alias <%= inspect schema.module %>
  alias <%= inspect schema.repo %>

  @doc """
  Returns the list of <%= schema.plural %>.

  ## Examples

      iex> <%= query.module %>.all()
      [%<%= inspect schema.alias %>{}, ...]

  """
  def all() do
    base()
    |> Repo.all()
  end

  @doc """
  Returns the last inserted <%= schema.plural %>.

  ## Examples

      iex> <%= query.module %>.last(3)
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

      iex> <%= query.module  %>.get!("44bff7b0-c9e4-4d5d-a6f3-61fb2c6dbddf")
      %<%= inspect schema.alias %>{}

  """
  def get!(id) do
    base()
    |> Repo.get!(id)
  end

  @doc """
  Gets a single <%= schema.singular %>.

  ## Examples

      iex> <%= query.module %>.get("44bff7b0-c9e4-4d5d-a6f3-61fb2c6dbddf")
      %<%= inspect schema.alias %>{}

  """
  def get(id) do
    base()
    |> Repo.get(id)
  end

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> <%= query.module %>.create(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> <%= query.module %>.create(%{field: bad_value})
      {:error, ...}

  """
  def create(attrs) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a <%= schema.singular %>.

  Raise an error if the <%= schema.human_singular %> could not be created.

  ## Examples

      iex> <%= query.module %>.create(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> <%= query.module %>.create(%{field: bad_value})
      {:error, ...}

  """
  def create!(attrs) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> <%= query.module %>(<%= schema.singular %>, %{field: new_value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> <%= query.module %>(<%= schema.singular %>, %{field: bad_value})
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

      iex> <%= query.module %>!(<%= schema.singular %>, %{field: new_value})
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

      iex> <%= query.module %>(<%= schema.singular %>)
      {:ok, %<%= inspect schema.alias %>{}}

  """
  def delete(model) do
    model
    |> Repo.delete()
  end

  @doc """
  Returns a data structure for tracking <%= schema.singular %> changes.

  ## Examples

      iex> <%= query.module %>.changeset(<%= schema.singular %>)
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
