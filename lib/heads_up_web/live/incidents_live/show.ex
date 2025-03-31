defmodule HeadsUpWeb.IncidentsLive.Show do
  alias HeadsUpWeb.Presence
  import HeadsUpWeb.{HeadlineComponents}
  alias HeadsUp.Responses.Response
  alias HeadsUp.Responses
  alias Phoenix.LiveView.AsyncResult
  alias HeadsUp.Incidents
  import HeadsUpWeb.BadgeComponents

  use HeadsUpWeb, :live_view

  def mount(_, _, socket) do
    {:ok, assign(socket, :form, to_form(Responses.change_response(%Response{})))}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    if connected?(socket) do
      Incidents.subscribe(id)

      %{current_user: current_user} = socket.assigns

      if current_user do
        {:ok, _} = Presence.track_incident(id, current_user.username)
      end

      Presence.subscribe_to_incident(id)
    end

    incident = Incidents.get_incident(id, [:category, heroic_response: :user])
    responses = Incidents.list_responses(incident)

    presences =
      Presence.list("incidents:#{id}")
      |> Enum.map(fn {username, %{metas: metas}} ->
        %{id: username, metas: metas}
      end)

    socket =
      socket
      |> assign(:page_title, incident.name)
      |> assign(:incident, incident)
      |> stream(:responses, responses)
      |> assign(:responses_count, Enum.count(responses))
      |> stream(:presences, presences)
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

    {:noreply, socket}
  end

  def handle_info({:response_created, response}, socket) do
    socket =
      socket
      |> stream_insert(:responses, response, at: 0)
      |> update(:responses_count, fn v -> v + 1 end)

    {:noreply, socket}
  end

  def handle_info({:incident_updated, incident}, socket) do
    socket =
      socket
      |> assign(:incident, incident)
      |> put_flash(:info, "Incident got updated")

    {:noreply, socket}
  end

  def handle_info({:user_joined, presence}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({:user_left, presence}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
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

  def handle_event("validate", %{"response" => response}, socket) do
    changeset = Responses.change_response(%Response{}, response)
    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"response" => response}, socket) do
    %{incident: incident, current_user: user} = socket.assigns

    case Responses.create_response(incident, user, response) do
      {:ok, created_response} ->
        Incidents.broadcast(incident.id, {:response_created, created_response})

        socket =
          socket
          |> assign(:form, to_form(Responses.change_response(%Response{})))
          |> stream_insert(:responses, created_response, at: 0)
          |> update(:responses_count, fn v -> v + 1 end)
          |> put_flash(:info, "Response created successfully")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))
          |> put_flash(:error, "Failed to create response")

        {:noreply, socket}
    end
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

  def on_lookers(assigns) do
    ~H"""
    <section>
      <h4>Onlookers</h4>
      <ul class="presences" id="onlookers" phx-update="stream">
        <li :for={{dom_id, %{id: username, metas: metas}} <- @presences} id={dom_id}>
          <.icon name="hero-user-circle-solid" class="w-5 h-5" /> {username} ({length(metas)})
        </li>
      </ul>
    </section>
    """
  end

  def response(assigns) do
    ~H"""
    <div class="response" id={@id}>
      <span class="timeline"></span>
      <section>
        <div class="avatar">
          <.icon name="hero-user-solid" />
        </div>
        <div>
          <span class="username">
            {@response.user.username}
          </span>
          <span>
            {@response.status}
          </span>
          <blockquote>
            {@response.note}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end
end
