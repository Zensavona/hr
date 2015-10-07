defmodule <%= base %>.Repo.Migrations.CreateIdentity do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :owner_id, references(:<%= plural %>)
      add :provider, :string, null: false
      add :access_token, :string, null: false
      add :refresh_token, :string
      add :uid, :string
      add :email, :string
      add :nickname
      add :image
      add :phone
      add :first_name
      add :last_name

      timestamps
    end
    create index(:<%= plural %>, [:owner_id])
    create unique_index(:identities, [:uid, :provider])
  end
end
