defmodule HeadsUpWeb.EffortLive do
  use HeadsUpWeb, :live_view

  def mount(_, _, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, 3000)
    end

    {:ok, assign(socket, page_title: "Effort", responders: 0, minutes_per_responder: 10)}
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    {:noreply, update(socket, :responders, fn v -> v + String.to_integer(quantity) end)}
  end

  def handle_event("change-time", %{"minutes" => minutes}, socket) do
    {:noreply, assign(socket, :minutes_per_responder, String.to_integer(minutes))}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 3000)
    {:noreply, update(socket, :responders, fn v -> v + 1 end)}
  end
end
