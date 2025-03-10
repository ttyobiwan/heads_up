defmodule HeadsUp.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias HeadsUp.Repo

  alias HeadsUp.Categories.Category

  @doc """
  Returns the list of categories.
  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.
  """
  def get_category!(id), do: Repo.get!(Category, id)

  def get_category_with_incidents!(id) do
    get_category!(id) |> Repo.preload(:incidents)
  end

  def get_category_options(fields) do
    query = from(c in Category, order_by: :name, select: map(c, ^fields))

    query
    |> Repo.all()
    |> Enum.map(fn map ->
      # Convert map response into a tuple that respects the initial order
      fields |> Enum.map(&map[&1]) |> List.to_tuple()
    end)
  end

  @doc """
  Creates a category.
  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.
  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.
  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.
  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
