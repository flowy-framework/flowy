defmodule <%= query.base_module %>.Tests.Fixtures.<%= inspect schema.alias %>Fixtures do
  @moduledoc """
  <%= inspect schema.human_singular %> fixtures.
  """

  alias <%= inspect schema.repo %>
  alias <%= inspect schema.module %>

  @doc """
  Generate a <%= schema.singular %>.
  """
  def <%= schema.singular %>_fixture(attrs \\ %{}) do
    attrs = default_attrs |> Map.merge(attrs)

    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert!()
  end

  def default_attrs do
    <%= Mix.Phoenix.to_text schema.params.create %>
  end
end
