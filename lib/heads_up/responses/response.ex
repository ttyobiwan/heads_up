defmodule HeadsUp.Responses.Response do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responses" do
    field :status, Ecto.Enum, values: [:enroute, :arrived, :departed]
    field :note, :string

    belongs_to :incident, HeadsUp.Incidents.Incident
    belongs_to :user, HeadsUp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:status, :note])
    |> validate_required([:status, :note, :incident, :user])
    |> validate_length(:note, max: 511)
    |> assoc_constraint(:incident)
    |> assoc_constraint(:user)
  end
end
