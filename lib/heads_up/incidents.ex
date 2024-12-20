defmodule HeadsUp.Incidents do
  alias HeadsUp.Repo
  alias HeadsUp.Incidents.Incident

  def list_incidents do
    Repo.all(Incident)
  end

  def get_incident(id) do
    Repo.get(Incident, id)
  end

  def list_urgent_incidents(incident) do
    List.delete(list_incidents(), incident)
  end
end
