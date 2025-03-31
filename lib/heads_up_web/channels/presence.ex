defmodule HeadsUpWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """

  use Phoenix.Presence,
    otp_app: :heads_up,
    pubsub_server: HeadsUp.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def track_incident(id, username) do
    track(self(), "incidents:#{id}", username, %{
      online_at: System.system_time(:second)
    })
  end

  def subscribe_to_incident(id) do
    Phoenix.PubSub.subscribe(HeadsUp.PubSub, "presences:incidents:#{id}")
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {username, %{metas: _metas}} <- joins do
      presence = %{id: username, metas: Map.fetch!(presences, username)}

      Phoenix.PubSub.local_broadcast(
        HeadsUp.PubSub,
        "presences:" <> topic,
        {:user_joined, presence}
      )
    end

    for {username, %{metas: _metas}} <- leaves do
      metas =
        case Map.fetch(presences, username) do
          {:ok, metas} -> metas
          :error -> []
        end

      presence = %{id: username, metas: metas}

      Phoenix.PubSub.local_broadcast(
        HeadsUp.PubSub,
        "presences:" <> topic,
        {:user_left, presence}
      )
    end

    {:ok, state}
  end
end
