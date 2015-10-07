defmodule Hr.UserHelper do
  import Ecto.Model

  @repo Hr.Meta.repo
  @model String.to_atom(Hr.Meta.model_module)
  @identity Hr.Meta.identity_model

  def create(changeset) do
    @repo.insert(changeset)
  end

  def create_with_identity(identity) do
    identity = @repo.transaction fn ->
      user = @repo.insert!(@model.__struct__)
      # Build an identity from the user model
      identity = Map.put(identity, :owner_id, user.id)
      identity = @repo.insert!(identity)
    end
    {:ok, identity} = identity
    identity |> HrDemo.Repo.preload(:owner) |> Map.fetch!(:owner)
  end

  def authenticate_with_identity(identity) do
    case @repo.get_by(@identity, [uid: identity.uid, provider: identity.provider], preload: [:owner]) do
      {:ok, identity} ->
        {:ok, identity.owner}
      _ ->
        {:error, nil}
    end
  end
end
