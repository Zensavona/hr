defmodule Hr.UserHelper do
  import Ecto.Model
  import Comeonin.Bcrypt, only: [checkpw: 2]
  import Joken

  def create_with_identity(repo, identity_model, model, entity, identity) do
    identity = repo.transaction fn ->
      user = repo.insert!(model.__struct__)
      # Build an identity from the user model
      identity = Map.put(identity, :"#{entity}_id", user.id)
      identity = repo.insert!(identity)
    end
    {:ok, identity} = identity
    identity |> repo.preload(:"#{entity}") |> Map.fetch!(:"#{entity}")
  end

  def authenticate_with_identity(repo, model, entity, identity) do
    case repo.get_by(model, [uid: identity.uid, provider: identity.provider]) do
      nil ->
        {:error, nil}
      identity ->
        user = identity |> repo.preload(:"#{entity}") |> Map.fetch!(:"#{entity}")
        {:ok, user}
    end
  end

  def authenticate_with_email_and_password(model, repo, email, password) do
    user = repo.get_by(model, email: email)
    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        {:error, :not_found}
    end
  end

  def get_with_id_and_token(repo, model, id, token) do
    user = repo.get_by(model, id: id)
    cond do
      user && checkpw(token, user.password_reset_token) ->
        {:ok, user}
      true ->
        {:error, "Invalid token or user id"}
    end
  end
end
