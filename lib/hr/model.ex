defmodule Hr.Model do
  defmacro __using__(_) do
    quote do
      use Ecto.Model
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      @model __MODULE__
      @repo __MODULE__ |> Module.split |> List.first |> Module.concat("Repo")

      @required ~w(email password)

      # Changesets
      def signup_changeset(params) do
        @model.__struct__
        |> cast(params, @required)
        |> validate_format(:email, ~r/@/)
        |> unique_constraint(:email)
        |> validate_length(:password, min: 6, max: 100)
        |> put_pass_hash
      end

      @doc """
      takes raw input and returns a model+token tuple with an unconfirmed
      email address and a hashed password.
      """
      def confirmable_signup_changeset(model, params) do
        token = YYID.new
        rtn = model
        |> cast(params, @required)
        |> validate_format(:email, ~r/@/)
        |> unique_constraint(:email)
        |> validate_length(:password, min: 6, max: 100)
        |> put_change(:confirmation_token, Comeonin.Bcrypt.hashpwsalt(token))
        |> put_pass_hash
        {rtn, token}
      end

      def unvalidate_email(changeset) do
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

      # Naughty functions that may have side effects
      ####

      def get_with_credentials(email, password) do
        query = from u in @model, where: u.email == ^email
        user = @repo.one query

        case Comeonin.Bcrypt.checkpw(password, user.password_hash) do
          true ->
            user |> @model.get_for_me |> @repo.one
          _ ->
            nil
        end
      end

      def get_with_id_and_token(id, token) do
        user = @repo.get_by(@model, id: id)
        cond do
          user && Comeonin.Bcrypt.checkpw(token, user.password_reset_token) ->
            {:ok, user}
          true ->
            {:error, "Invalid token or user id"}
        end
      end

      def get_for_me(user) do
        from u in @model,
        where: u.id == ^user.id,
        select: %{id: u.id, email: u.email}
      end

      # Behaviour helpers
      ####
      def confirmable?, do: Enum.member?(@model.behaviours, :confirmable)

      # Convenience Helpers
      ####

      def repo, do: @repo

      # Private functions
      ####
      defp put_pass_hash(changeset) do
        case changeset do
          %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
            put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
          _ ->
            changeset
        end
      end

      defp validate_token(changeset) do
        token_matches = Comeonin.Bcrypt.checkpw(changeset.params["confirmation_token"], changeset.model. confirmation_token)
        do_validate_token token_matches, changeset
      end

      defp do_validate_token(true, changeset), do: changeset
      defp do_validate_token(false, changeset) do
        add_error changeset, :confirmation_token, :invalid
      end
    end
  end
end


# defmodule Hr.Model do
#   @moduledoc """
#   Provides changesets for interacting with HRable models internally
#   """
#   import Ecto.Changeset
#   @required ~w(email password)

# 
#   def oauth_signup_changeset(model, params) do
#     model
#     |> cast(params, ~w(uid, provider, owner_id), ~w(access_token refresh_token email nickname image phone # first_name last_name))
#   end
# 
#   def session_changeset(model, params) do
#     model
#     |> cast(params, @required)
#     |> put_pass_hash
#   end
# 
#   def confirmation_changeset(user = %{confirmed_at: nil}, params) do
#     cast(user, params, [])
#     |> put_change(:unconfirmed_email, nil)
#     |> put_change(:email, user.unconfirmed_email)
#     |> put_change(:confirmed_at, Ecto.DateTime.local)
#     |> validate_token
#   end
#   def confirmation_changeset(user = %{unconfirmed_email: unconfirmed_email}, params) when unconfirmed_email !=#  nil do
#     cast(user, params, [])
#     |> put_change(:unconfirmed_email, nil)
#     |> put_change(:email, user.unconfirmed_email)
#     |> put_change(:confirmed_at, Ecto.DateTime.local)
#     |> validate_token
#   end
# 
#   def confirmation_changeset(_, _) do
#     nil
#   end
# 
#   def reset_changeset(user) do
#     token = YYID.new
#     changeset = user
#     |> cast(%{}, [])
#     |> put_change(:password_reset_token, Comeonin.Bcrypt.hashpwsalt(token))
# 
#     {changeset, token}
#   end
# 
#   def new_password_changeset(user, params) do
#     cast(user, params, ~w(password password_reset_token))
#     |> validate_length(:password, min: 6, max: 100)
#     |> put_pass_hash
#     |> put_change(:password_reset_token, nil)
#   end
# 
#   defp validate_token(changeset) do
#     token_matches = Comeonin.Bcrypt.checkpw(changeset.params["confirmation_token"], changeset.model.# confirmation_token)
#     do_validate_token token_matches, changeset
#   end
# 
#   defp do_validate_token(true, changeset), do: changeset
#   defp do_validate_token(false, changeset) do
#     add_error changeset, :confirmation_token, :invalid
#   end
# 
#   defp unvalidate_email(changeset) do
#     case changeset do
#       %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
#         changeset
#         |> put_change(:email, nil)
#         |> put_change(:unconfirmed_email, email)
#         |> put_change(:confirmation_sent_at, Ecto.DateTime.local)
#       _ ->
#         changeset
#     end
#   end
# 
#   def put_pass_hash(changeset) do
#     case changeset do
#       %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
#         put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
#       _ ->
#         changeset
#     end
#   end
# end
