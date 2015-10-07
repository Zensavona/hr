defmodule Hr.Repo do
  @repo Hr.Meta.repo
  @model String.to_atom(Hr.Meta.model_module)

  # use 'use' here ffs

  def insert(changeset) do
    @repo.insert(changeset)
  end

  def get_user(list) do
    @repo.get_by(@model, list)
  end

  def get_user_from_oauth(model, provider, oauth_user) do
    @repo.get_by(model, [uid: to_string(oauth_user["id"]), provider: provider])
  end

  def transaction(func) do
    @repo.transaction(func)
  end
end
