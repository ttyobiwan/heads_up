defmodule HeadsUpWeb.Admin.IncidentsLive.Index do
  use HeadsUpWeb, :live_view

  alias HeadsUp.Incidents.Admin
  import HeadsUpWeb.BadgeComponents

  def mount(_, _, socket) do
    {:ok, socket |> assign(page_title: "Admin") |> stream(:incidents, Admin.list_incidents())}
  end
end
