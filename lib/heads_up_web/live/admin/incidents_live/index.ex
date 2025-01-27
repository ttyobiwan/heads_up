defmodule HeadsUpWeb.Admin.IncidentsLive.Index do
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
end
