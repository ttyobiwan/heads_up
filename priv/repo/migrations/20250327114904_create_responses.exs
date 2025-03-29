defmodule HeadsUp.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :status, :string
      add :note, :text, null: false
      add :incident_id, references(:incidents, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:responses, [:incident_id])
    create index(:responses, [:user_id])
  end
end
