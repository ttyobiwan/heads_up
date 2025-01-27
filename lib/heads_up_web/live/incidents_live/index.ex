defmodule HeadsUpWeb.IncidentsLive.Index do
  use HeadsUpWeb, :live_view

  import HeadsUpWeb.{BadgeComponents, HeadlineComponents}
  alias Phoenix.HTML.Form
  alias HeadsUp.Incidents
  alias HeadsUp.Incidents.Incident

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(page_title: "Incidents")}
  end

  def handle_params(params, _, socket) do
    {:noreply,
     socket
     |> assign(form: to_form(params))
     |> stream(:incidents, Incidents.filter_home_incidents(params), reset: true)}
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status sort_by))
      # Remove empty state, including filter defaults
      |> Map.reject(fn {_, v} -> v in ["", "status", "sort_by"] end)

    {:noreply, push_patch(socket, to: ~p"/incidents?#{params}")}
  end

  attr :form, Form, required: true
  attr :rest, :global

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} {@rest}>
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="1000" />
      <.input
        field={@form[:status]}
        type="select"
        placeholder="Status"
        options={[Status: "status", Pending: "pending", Resolved: "resolved", Cancelled: "cancelled"]}
      />
      <.input
        field={@form[:sort_by]}
        type="select"
        placeholder="Sort by"
        options={["Sort By": "sort_by", Name: "name", Priority: "priority"]}
      />
      <.link patch={~p"/incidents"}>Reset</.link>
    </.form>
    """
  end

  attr :incident, Incident, required: true
  attr :rest, :global

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident.id}"} {@rest}>
      <div class="card">
        <img src={@incident.image_path || "/images/placeholder.jpg"} />
        <h2>{@incident.name}</h2>
        <div class="details">
          <.badge status={@incident.status} />
          <div class="priority">
            {@incident.priority}
          </div>
        </div>
      </div>
    </.link>
    """
  end
end
