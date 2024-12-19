defmodule HeadsUpWeb.IncidentsLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.{Incident, Incidents}
  import HeadsUpWeb.{BadgeComponents, HeadlineComponents}

  def mount(_, _, socket) do
    {:ok, assign(socket, page_title: "Incidents", incidents: Incidents.list_incidents())}
  end

  attr :incident, Incident, required: true
  attr :rest, :global

  def incident_card(assigns) do
    ~H"""
    <.link navigate={~p"/incidents/#{@incident.id}"}>
      <div class="card" {@rest}>
        <img src={@incident.image_path} />
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
