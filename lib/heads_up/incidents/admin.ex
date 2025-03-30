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

  # def get_incident_with_category!(id) do
  #   get_incident!(id) |> Repo.preload(:category)
  # end

  def update_incident(incident, params) do
    incident
    |> Incident.changeset(params)
    |> Repo.update()
    |> case do
      {:ok, incident} ->
        incident = Repo.preload(incident, [:category, heroic_response: :user])
        {:ok, incident}

      {:error, changeset} ->
        {:error, changeset}
    end
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

  def draw_heroic_response(%Incident{status: :resolved, heroic_response_id: nil} = incident) do
    incident
    |> Ecto.assoc(:responses)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
    |> case do
      nil -> {:error, "Incident has no responses"}
      response -> {:ok, response}
    end
  end

  def draw_heroic_response(%Incident{}) do
    {:error, "Incident is either unresolved or has heroic response assigned"}
  end
end
