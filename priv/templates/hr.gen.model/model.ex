defmodule <%= module %> do
  use <%= base %>.Web, :model
  use Hr.Behaviours, [:registerable, :database_authenticatable, :recoverable, :confirmable]
  # optionally add :oauthable to authenticate <%= plural %> with the oauth providers you specify in config/hr.exs
  # optionally add :jwt_refreshable if you are using JWT token auth and want to refresh your tokens on an interval

  schema <%= inspect plural %> do
<%= for {k, _} <- attrs do %>    field <%= inspect k %>, <%= inspect types[k] %><%= defaults[k] %>
<% end %>
    field :password, :string, virtual: :true
    field :email, :string
    field :unconfirmed_email, :string
    field :password_hash, :string
    field :confirmation_token, :string
    field :confirmed_at, Ecto.DateTime
    field :confirmation_sent_at, Ecto.DateTime
    field :password_reset_token, :string
    field :reset_password_sent_at, Ecto.DateTime
    field :failed_attempts, :integer, default: 0
    field :locked_at, Ecto.DateTime
    has_many :<%= singular %>_identities, <%= base %>.<%= alias %>Identity
<%= for {k, _, m, _} <- assocs do %>    belongs_to <%= inspect k %>, <%= m %>
<% end %>
    timestamps
  end

  @required_fields ~w(<%= Enum.map_join(attrs, " ", &elem(&1, 0)) %>)
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
