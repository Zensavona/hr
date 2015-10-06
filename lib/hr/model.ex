defmodule Hr.Model do
  import Ecto.Changeset

  def signup_changeset(model, params) do
    model
      |> cast(params, ~w(email password))
      |> validate_format(:email, ~r/@/) # replace this with something more robust
      |> unique_constraint(:email)
      |> validate_length(:password, min: 6, max: 100)
      |> put_pass_hash
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
