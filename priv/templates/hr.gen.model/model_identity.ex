defmodule <%= module %>Identity do
  use <%= base %>.Web, :model

  schema "<%= singular %>_identities" do
    field :provider, :string
    field :access_token, :string
    field :refresh_token, :string
    field :uid, :string
    field :email, :string
    field :nickname, :string
    field :image, :string
    field :phone, :string
    field :first_name, :string
    field :last_name, :string

    belongs_to :<%= singular %>, <%= base %>.<%= alias %>
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
