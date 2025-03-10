defmodule HeadsUpWeb.Api.CategoriesJSON do
  def show_incidents(%{incidents: incidents}) do
    Enum.map(incidents, fn i ->
      %{
        id: i.id,
        name: i.name,
        priority: i.priority,
        status: i.status,
        description: i.description,
        image_path: i.image_path,
        category_id: i.category_id,
        inserted_at: i.inserted_at,
        updated_at: i.updated_at
      }
    end)
  end
end
