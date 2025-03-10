defmodule HeadsUpWeb.IncidentsLive.Show do
  use HeadsUpWeb, :live_view
  alias Phoenix.LiveView.AsyncResult

  alias HeadsUp.Incidents
  import HeadsUpWeb.BadgeComponents

  def mount(%{"id" => id}, _, socket) do
    incident = Incidents.get_incident_with_category(String.to_integer(id))

    socket =
      socket
      |> assign(:page_title, incident.name)
      |> assign(:incident, incident)
      |> assign(:urgent_incidents, AsyncResult.loading())
      |> start_async(:fetch_urgent_incidents, fn ->
        IO.puts("Fetching urgent incidents")
        Incidents.list_urgent_incidents(incident)
      end)

    # We do start_async+handle_async instead of:
    # |> assign_async(:urgent_incidents, fn ->
    #   # {:error, "couldn't get urgent incidents"}
    #   {:ok, %{urgent_incidents: Incidents.list_urgent_incidents(incident)}}
    # end)

    {:ok, socket}
  end

  def handle_async(:fetch_urgent_incidents, {:ok, incidents}, socket) do
    IO.puts("Finished fetching urgent incidents")
    result = AsyncResult.ok(socket.assigns.urgent_incidents, incidents)
    {:noreply, assign(socket, :urgent_incidents, result)}
  end

  def handle_async(:fetch_urgent_incidents, {:exit, {%RuntimeError{message: message}, _}}, socket) do
    IO.puts("Failed to fetch urgent incidents :#{message}")
    result = AsyncResult.failed(socket.assigns.urgent_incidents, {:error, message})
    {:noreply, assign(socket, :urgent_incidents, result)}
  end

  def handle_async(:fetch_urgent_incidents, {:exit, reason}, socket) do
    IO.puts("Failed to fetch urgent incidents :#{reason}")
    result = AsyncResult.failed(socket.assigns.urgent_incidents, {:error, reason})
    {:noreply, assign(socket, :urgent_incidents, result)}
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
              <img src={incident.image_path || "/images/placeholder.jpg"} />{incident.name}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end
end
