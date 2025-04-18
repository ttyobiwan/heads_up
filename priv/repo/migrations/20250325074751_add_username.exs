defmodule HeadsUp.Repo.Migrations.AddUsername do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string, null: false, size: 63
    end

    create unique_index(:users, [:username])
  end
end
