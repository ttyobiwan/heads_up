defmodule HeadsUpWeb.EffortLive do
  use HeadsUpWeb, :live_view

  def mount(_, _, socket) do
    {:ok, assign(socket, responders: 0, minutes_per_responder: 10)}
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    {:noreply, update(socket, :responders, fn v -> v + String.to_integer(quantity) end)}
  end
end
