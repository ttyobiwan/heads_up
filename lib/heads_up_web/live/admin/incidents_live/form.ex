defmodule HeadsUpWeb.Admin.IncidentsLive.Form do
  alias HeadsUp.Incidents
  alias HeadsUp.Categories
  use HeadsUpWeb, :live_view
  alias HeadsUp.Incidents.Incident
  alias HeadsUp.Incidents.Admin

  def mount(params, _, socket) do
    {:ok, set_action(socket.assigns.live_action, socket, params)}
  end

  def handle_event("save", %{"incident" => params}, socket) do
    save_incident(socket.assigns.live_action, params, socket)
  end

  def handle_event("change", %{"incident" => params}, socket) do
    cs = Incident.changeset(socket.assigns.incident, params)
    socket = assign(socket, form: to_form(cs, action: :validate))
    {:noreply, socket}
  end

  defp set_action(:new, socket, _) do
    incident = %Incident{}
    cs = Incident.changeset(incident, %{})
    categories = Categories.get_category_options([:name, :id])

    socket
    |> assign(page_title: "New Incident")
    |> assign(incident: incident)
    |> assign(categories: categories)
    |> assign(form: to_form(cs))
  end

  defp set_action(:edit, socket, %{"id" => id}) do
    incident = Admin.get_incident!(id)
    cs = Incident.changeset(incident, %{})
    categories = Categories.get_category_options([:name, :id])

    socket
    |> assign(page_title: "Edit Incident")
    |> assign(incident: incident)
    |> assign(categories: categories)
    |> assign(form: to_form(cs))
  end

  defp save_incident(:new, params, socket) do
    case Admin.create_incident(params) do
      {:ok, incident} ->
        socket =
          socket
          |> put_flash(:info, "Incident '#{incident.name}' created successfully")
          |> push_navigate(to: ~p"/admin/incidents")

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, form: to_form(changeset))
        {:noreply, socket}
    end
  end

  defp save_incident(:edit, params, socket) do
    case Admin.update_incident(socket.assigns.incident, params) do
      {:ok, incident} ->
        Incidents.broadcast(incident.id, {:incident_updated, incident})

        socket =
          socket
          |> put_flash(:info, "Incident '#{incident.name}' updated successfully")
          |> push_navigate(to: ~p"/admin/incidents")

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, form: to_form(changeset))
        {:noreply, socket}
    end
  end
end
