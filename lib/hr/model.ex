defmodule Hr.Model do
  import Ecto.Changeset
  @required ~w(email password)

  def signup_changeset(model, params) do
    model
    |> cast(params, @required)
    |> validate_format(:email, ~r/@/) # replace this with something more robust
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash
  end

  def oauth_signup_changeset(model, params) do
    model
    |> cast(params, ~w(uid, provider, owner_id), ~w(access_token refresh_token email nickname image phone first_name last_name))
  end

  def session_changeset(model, params) do
    model
    |> cast(params, @required)
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
