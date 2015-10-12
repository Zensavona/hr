defmodule Hr.Model do
  import Ecto.Changeset
  @required ~w(email password)

  def signup_changeset(model, params) do
    token = YYID.new
    rtn = model
    |> cast(params, @required)
    |> validate_format(:email, ~r/@/) # replace this with something more robust
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> unvalidate_email
    |> put_change(:confirmation_token, Comeonin.Bcrypt.hashpwsalt(token))
    |> put_pass_hash
    {rtn, token}
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
    |> put_change(:email, user.unconfirmed_email)
    |> put_change(:confirmed_at, Ecto.DateTime.local)
    |> validate_token
  end
  def confirmation_changeset(user = %{unconfirmed_email: unconfirmed_email}, params) when unconfirmed_email != nil do
    cast(user, params, [])
    |> put_change(:unconfirmed_email, nil)
    |> put_change(:email, user.unconfirmed_email)
    |> put_change(:confirmed_at, Ecto.DateTime.local)
    |> validate_token
  end

  def reset_changeset(user) do
    token = YYID.new
    changeset = user
    |> cast(%{}, [])
    |> put_change(:password_reset_token, Comeonin.Bcrypt.hashpwsalt(token))

    {changeset, token}
  end

  def new_password_changeset(user, params) do
    cast(user, params, ~w(password password_reset_token))
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash
    |> put_change(:password_reset_token, nil)
  end

  defp validate_token(changeset) do
    token_matches = Comeonin.Bcrypt.checkpw(changeset.params["confirmation_token"], changeset.model.confirmation_token)
    do_validate_token token_matches, changeset
  end

  defp do_validate_token(true, changeset), do: changeset
  defp do_validate_token(false, changeset) do
    add_error changeset, :confirmation_token, :invalid
  end

  defp unvalidate_email(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
        changeset
        |> put_change(:email, nil)
        |> put_change(:unconfirmed_email, email)
        |> put_change(:confirmation_sent_at, Ecto.DateTime.local)
      _ ->
        changeset
    end
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
