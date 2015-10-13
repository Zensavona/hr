defmodule <%= base %>.Repo.Migrations.Create<%= scoped %>Identities do
  use Ecto.Migration

  def change do
    create table(:<%= singular %>_identities) do
      add :<%= singular %>_id, references(:<%= plural %>)
      add :provider, :string, null: false
      add :access_token, :string, null: false
      add :refresh_token, :string
      add :uid, :string
      add :email, :string
      add :nickname, :string
      add :image, :string
      add :phone, :string
      add :first_name, :string
      add :last_name, :string

      timestamps
    end
    create index(:<%= plural %>, [:id])
    create unique_index(:<%= singular %>_identities, [:uid, :provider])
  end
end
