defmodule HeadsUpWeb.IncidentsLive.Show do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents
  import HeadsUpWeb.BadgeComponents

  def mount(%{"id" => id}, _, socket) do
    incident = Incidents.get_incident(String.to_integer(id))

    socket =
      socket
      |> assign(:page_title, incident.name)
      |> assign(:incident, incident)
      |> assign_async(:urgent_incidents, fn ->
        # {:error, "couldn't get urgent incidents"}
        {:ok, %{urgent_incidents: Incidents.list_urgent_incidents(incident)}}
      end)

    {:ok, socket}
  end

  attr :incidents, :list, required: true

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <.async_result :let={result} assign={@incidents}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">Something went wrong: {reason}</div>
        </:failed>
        <ul class="incidents">
          <li :for={incident <- result}>
            <.link navigate={~p"/incidents/#{incident.id}"}>
              <img src={incident.image_path} />{incident.name}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
