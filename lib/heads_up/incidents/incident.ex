defmodule HeadsUp.Incidents.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :name, :string
    field :priority, :integer, default: 1
    field :status, Ecto.Enum, values: [:pending, :resolved, :cancelled], default: :pending
    field :description, :string
    field :image_path, :string, default: nil

    belongs_to :category, HeadsUp.Categories.Category

    timestamps(type: :utc_datetime)
  end

  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [:name, :description, :priority, :status, :image_path, :category_id])
    |> validate_required([:name, :description, :category_id])
    |> validate_length(:name, min: 3, max: 255)
    |> validate_length(:description, min: 3, max: 1023)
    |> validate_number(:priority, greater_than: 0)
    |> assoc_constraint(:category)
  end
end
