defmodule <%= base %>.Repo.Migrations.Create<%= scoped %> do
  use Ecto.Migration

  def change do
    create table(:<%= plural %><%= if binary_id do %>, primary_key: false<% end %>) do
<%= if binary_id do %>      add :id, :binary_id, primary_key: true<% end %>
      add :email, :string
      add :unconfirmed_email, :string
      add :password_hash, :string
      add :confirmation_token, :string
      add :confirmed_at, :datetime
      add :confirmation_sent_at, :datetime
      add :password_reset_token, :string
      add :reset_password_sent_at, :datetime
      add :failed_attempts, :integer, default: 0, null: false
      add :locked_at, :datetime
<%= for {k, v} <- attrs do %>      add <%= inspect k %>, <%= inspect v %><%= defaults[k] %>
<% end %><%= for {_, i, _, s} <- assocs do %>      add <%= inspect i %>, references(<%= inspect(s) %><%= if binary_id do %>, type: :binary_id<% end %>)
<% end %>
      timestamps
    end
<%= for index <- indexes do %>    <%= index %>
<% end %>
    create unique_index(:<%= plural %>, [:email])
    create unique_index(:<%= plural %>, [:confirmation_token])
    create unique_index(:<%= plural %>, [:password_reset_token])
  end
end
