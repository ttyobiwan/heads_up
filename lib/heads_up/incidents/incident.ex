defmodule HeadsUp.Incidents.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :name, :string
    field :priority, :integer, default: 1
    field :status, Ecto.Enum, values: [:pending, :resolved, :cancelled], default: :pending
    field :description, :string
    field :image_path, :string, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :description, :priority, :status, :image_path])
    |> validate_required([:name, :description])
    |> validate_length(:name, min: 3, max: 255)
    |> validate_length(:description, min: 3, max: 1023)
    |> validate_number(:priority, greater_than: 0)
  end
end
