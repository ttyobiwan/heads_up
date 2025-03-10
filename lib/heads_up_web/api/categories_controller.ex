defmodule HeadsUpWeb.Api.CategoriesController do
  use HeadsUpWeb, :controller
  alias HeadsUp.Categories

  def show_incidents(conn, %{"id" => id}) do
    # incidents = Incidents.get_incidents_by_category(id)
    category = Categories.get_category_with_incidents!(id)
    conn |> assign(:incidents, category.incidents) |> render(:show_incidents)
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> put_view(json: HeadsUpWeb.ErrorJSON)
      |> render(:"404")
  end
end
