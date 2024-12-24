defmodule HeadsUp.Incidents do
  import Ecto.Query

  alias HeadsUp.Repo
  alias HeadsUp.Incidents.Incident

  # def statuses() do
  #   Ecto.Enum.values(Incident, :status)
  # end

  def list_incidents do
    Repo.all(Incident)
  end

  def get_incident(id) do
    Repo.get(Incident, id)
  end

  def list_home_incidents() do
    Repo.all(Incident)
  end

  def filter_home_incidents(params) do
    Incident
    |> with_search(params["q"])
    |> with_status(params["status"])
    |> with_sort_by(params["sort_by"])
    |> Repo.all()
  end

  defp with_search(query, q) when q in ["", nil], do: query
  defp with_search(query, q), do: where(query, [i], ilike(i.name, ^"%#{q}%"))

  defp with_status(query, status) when status in ["status", "", nil], do: query
  defp with_status(query, status), do: where(query, [i], i.status == ^status)

  defp with_sort_by(query, sort_by) when sort_by in ["sort_by", "", nil], do: query
  defp with_sort_by(query, sort_by), do: order_by(query, desc: ^String.to_existing_atom(sort_by))

  def list_urgent_incidents(selected_incident) do
    Repo.all(
      from i in Incident,
        where: i.status == :pending and i.id != ^selected_incident.id,
        order_by: [desc: i.priority],
        limit: 3
    )
  end
end
