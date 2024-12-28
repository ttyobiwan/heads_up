defmodule HeadsUp.Incidents.Admin do
  import Ecto.Query
  alias HeadsUp.Repo
  alias HeadsUp.Incidents.Incident

  def list_incidents do
    Incident |> order_by(desc: :inserted_at) |> Repo.all()
  end
end
