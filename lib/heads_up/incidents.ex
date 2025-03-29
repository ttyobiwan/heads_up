defmodule HeadsUp.Incidents do
  import Ecto.Query

  alias HeadsUp.Categories.Category
  alias HeadsUp.Repo
  alias HeadsUp.Incidents.Incident

  # def statuses() do
  #   Ecto.Enum.values(Incident, :status)
  # end

  def list_incidents do
    Repo.all(Incident)
  end

  def list_responses(incident) do
    incident
    |> Ecto.assoc(:responses)
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  def get_incident(id) do
    Repo.get(Incident, id)
  end

  def get_incident(id, preloads) do
    Repo.get(Incident, id) |> Repo.preload(preloads)
  end

  def get_incident_with_category(id) do
    get_incident(id) |> Repo.preload(:category)
  end

  def get_incidents_by_category(category_id) do
    Repo.all(from i in Incident, where: i.category_id == ^category_id)
  end

  def list_home_incidents() do
    Repo.all(Incident)
  end

  def filter_home_incidents(params) do
    Incident
    |> with_search(params["q"])
    |> with_status(params["status"])
    |> with_category(params["category"])
    |> with_sort_by(params["sort_by"])
    |> preload(:category)
    |> Repo.all()
  end

  defp with_search(query, q) when q in ["", nil], do: query
  defp with_search(query, q), do: where(query, [i], ilike(i.name, ^"%#{q}%"))

  defp with_status(query, status) when status in ["status", "", nil], do: query
  defp with_status(query, status), do: where(query, [i], i.status == ^status)

  defp with_category(query, category) when category in ["", nil], do: query

  defp with_category(query, category),
    do:
      from(i in query, join: c in Category, on: c.id == i.category_id, where: c.slug == ^category)

  defp with_sort_by(query, sort_by) when sort_by in ["sort_by", "", nil], do: query

  defp with_sort_by(query, "category"),
    do: from(i in query, join: c in assoc(i, :category), order_by: c.name)

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
