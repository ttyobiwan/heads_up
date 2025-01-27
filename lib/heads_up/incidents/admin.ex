defmodule HeadsUp.Incidents.Admin do
  import Ecto.Query
  alias HeadsUp.Repo
  alias HeadsUp.Incidents.Incident

  def create_incident(params) do
    %Incident{}
    |> Incident.changeset(params)
    |> Repo.insert()
  end

  def list_incidents do
    Incident
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def update_incident(incident, params) do
    incident
    |> Incident.changeset(params)
    |> Repo.update()
  end

  def delete_incident(id) do
    Incident
    |> where([i], i.id == ^id)
    |> Repo.delete_all()

    # or
    # Repo.delete_all(from(i in Incident, where: i.id == ^id))
    # or
    # Repo.get!(Incident, id) |> Repo.delete()
    # or
    # Repo.delete(%Incident{id: id})
  end
end
