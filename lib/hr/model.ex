defmodule Hr.Model do
  import Ecto.Changeset
  @required ~w(email password)

  def signup_changeset(model, params) do
    model
    |> cast(params, @required)
    |> validate_format(:email, ~r/@/) # replace this with something more robust
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> unvalidate_email
    |> add_confirmation_token
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

  def confirmation_changeset(user = %{confirmed_at: nil}, params) do
    cast(user, params, [])
    |> put_change(:unconfirmed_email, nil)
    |> put_change(:confirmed_at, Ecto.DateTime.local)
    |> validate_token
  end
  def confirmation_changeset(user = %{unconfirmed_email: unconfirmed_email}, params) when unconfirmed_email != nil do
    cast(user, params, [])
    |> put_change(:hashed_confirmation_token, nil)
    |> put_change(:unconfirmed_email, nil)
    |> put_change(:email, unconfirmed_email)
    |> validate_token
  end

  defp validate_token(changeset) do
    token_matches = changeset.model.confirmation_token == changeset.params["confirmation_token"]
    do_validate_token token_matches, changeset
  end

  defp do_validate_token(true, changeset), do: changeset
  defp do_validate_token(false, changeset) do
    add_error changeset, :confirmation_token, :invalid
  end

  defp unvalidate_email(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
        changeset = put_change(changeset, :email, nil)
        put_change(changeset, :unconfirmed_email, email)
      _ ->
        changeset
    end
  end

  defp add_confirmation_token(changeset) do
    put_change(changeset, :confirmation_token, YYID.new)
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
