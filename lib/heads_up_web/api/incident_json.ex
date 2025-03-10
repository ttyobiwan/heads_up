defmodule HeadsUpWeb.Api.IncidentJSON do
  def index(%{incidents: incidents}) do
    Enum.map(incidents, &to_json(&1))
  end

  def show(%{incident: i}) do
    to_json(i)
  end

  def create(%{incident: i}) do
    to_json(i)
  end

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp to_json(incident) do
    %{
      id: incident.id,
      name: incident.name,
      priority: incident.priority,
      status: incident.status,
      description: incident.description,
      image_path: incident.image_path,
      category_id: incident.category_id,
      inserted_at: incident.inserted_at,
      updated_at: incident.updated_at
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
