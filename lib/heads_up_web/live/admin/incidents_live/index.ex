defmodule HeadsUpWeb.Admin.IncidentsLive.Index do
  alias HeadsUp.Incidents
  alias HeadsUp.Incidents.Incident
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents.Admin
  import HeadsUpWeb.BadgeComponents

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(page_title: "Admin")
     |> stream(:incidents, Admin.list_incidents())}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Admin.delete_incident(id)

    {:noreply,
     socket
     |> put_flash(:info, "Incident #{id} deleted successfully")
     |> stream_delete(:incidents, %Incident{id: id})}
  end

  def handle_event("draw-heroic", %{"id" => id}, socket) do
    incident = Incidents.get_incident!(id)

    incident
    |> Admin.draw_heroic_response()
    |> case do
      {:ok, response} ->
        {:ok, incident} = Incidents.update_incident(incident, %{heroic_response_id: response.id})
        Incidents.broadcast(incident.id, {:incident_updated, incident})

        socket =
          socket
          |> put_flash(:info, "Heroic response picked successfully")
          |> stream_insert(:incidents, incident)

        {:noreply, socket}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, err)}
    end
  end
end
