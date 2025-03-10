defmodule HeadsUpWeb.Api.IncidentController do
  use HeadsUpWeb, :controller
  alias HeadsUp.Incidents
  alias HeadsUp.Incidents.Admin

  def index(conn, _) do
    incidents = Incidents.list_incidents()
    conn |> assign(:incidents, incidents) |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    case Incidents.get_incident(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(json: HeadsUpWeb.ErrorJSON)
        |> render(:"404")

      incident ->
        conn |> assign(:incident, incident) |> render(:show)
    end
  end

  def create(conn, params) do
    case Admin.create_incident(params) do
      {:ok, incident} ->
        conn |> put_status(:created) |> assign(:incident, incident) |> render(:create)

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> assign(:changeset, cs) |> render(:error)
    end
  end
end
