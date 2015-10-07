defmodule Hr.Repo do
  @repo Hr.Meta.repo
  @model String.to_atom(Hr.Meta.model_module)

  def insert(changeset) do
    @repo.insert(changeset)
  end

  def get_user(list) do
    @repo.get_by(@model, list)
  end
end
