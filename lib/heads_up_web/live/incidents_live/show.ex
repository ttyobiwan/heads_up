defmodule HeadsUpWeb.IncidentsLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  import HeadsUpWeb.BadgeComponents

  def mount(%{"id" => id}, _, socket) do
    incident = Incidents.get_incident(String.to_integer(id))
    {:ok, assign(socket, page_title: incident.name, incident: incident)}
  end

  attr :incidents, :list, required: true

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <ul class="incidents">
        <li :for={incident <- @incidents}>
          <.link navigate={~p"/incidents/#{incident.id}"}>
            <img src={incident.image_path} />{incident.name}
          </.link>
        </li>
      </ul>
    </section>
    """
  end
end
