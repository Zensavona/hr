defmodule Hr.BaseJWTController do
  @moduledoc """
  Base form controller. Can be "inherited" from by using `use Hr.BaseJWTController`.
  A good example of this is in `Hr.JWTController`
   """
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller

      @doc """
      Check if the submitted credentials are valid, if they are, create a session
      """
      def create_session(conn, %{"email" => email, "password" => password}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.UserHelper.authenticate_with_email_and_password(model, repo, email, password) do
          {:ok, user} ->
            token = Hr.JWT.create(conn, entity, user)
            conn |> render("authenticate.json", token: token)
          {:error, _reason} ->
            conn
            |> put_status(:unauthorized)
            |> render("error.json", errors: ["Invalid credentials"])
        end
      end

      @doc """
      Create a new user if the email address isn't already taken.
      """
      def create_signup(conn, data) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        params = data[entity]
        confirmable? = Enum.member? model.hr_behaviours, :confirmable

        if confirmable? do
          {changeset, token} = Hr.Model.confirmable_signup_changeset(model.__struct__, params)
        else
          changeset = Hr.Model.signup_changeset(model.__struct__, params)
        end

        case repo.insert(changeset) do
          {:ok, user} ->
            if confirmable? do
              link = Hr.Meta.confirmation_url(conn, user.id, token)
              Hr.Meta.mailer(app).send_confirmation_email(user, link)
              conn
              |> render("generic_flash.json", flash: Hr.Meta.i18n(app, "registrations.signed_up_but_unconfirmed", email: user.unconfirmed_email))
            else
              token = Hr.JWT.create(conn, entity, user)
              conn |> render("authenticate.json", token: token)
            end
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", errors: changeset)
        end
      end

      @doc """
      Confirms the email for the user
      """
      def confirmation(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        user = repo.get! model, user_id
        changeset = Hr.Model.confirmation_changeset(user, params)

        if changeset && changeset.valid? do
          repo.update!(changeset)
          conn
          |> render("generic_flash.json", flash: Hr.Meta.i18n(app, "confirmations.confirmed"))
        else
          conn
          |> put_status(:unprocessable_entity)
          |> render("error.json", errors: changeset)
        end
      end

      @doc """
      If the email exists, send a reset link
      """
      def create_password_reset_request(conn, %{"reset" => %{"email" => email}}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        user = repo.get_by! model, email: email

        case user do
          nil ->
            nil
          user ->
            {changeset, token} = Hr.Model.reset_changeset(user)
            repo.update!(changeset)
            link = Hr.Meta.reset_url(conn, user.id, token)
            Hr.Meta.mailer(app).send_reset_email(user, link)
        end
        render(conn, "generic_flash.json", flash: Hr.Meta.i18n(app, "passwords.send_instructions"))
      end

      @doc """
      Reset the user's password
      """
      def create_password_reset(conn, %{"reset" => params}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.UserHelper.get_with_id_and_token(repo, model, params["id"], params["password_reset_token"]) do
          {:ok, user} ->
            changeset = Hr.Model.new_password_changeset(user, params)
            if changeset.valid? do
              repo.update!(changeset)
              render(conn, "generic_flash.json", flash: Hr.Meta.i18n(app, "passwords.updated"))
            else
              conn
              |> put_status(:unauthorized)
              |> render("error.json", errors: changeset)
              # |> put_flash(:error, Hr.Meta.i18n(app, "passwords.invalid"))
            end
          {:error, _} ->
            conn
            |> put_status(:unauthorized)
            |> render("error.json", errors: Hr.Meta.i18n(app, "passwords.no_token"))
        end
      end

      def create_refreshed_token(conn, %{"token" => token}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.JWT.refresh(conn, token) do
          {:ok, fresh} ->
            conn |> render("authenticate.json", token: fresh)
          {:error, error} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", errors: [error])
        end
      end
    end
  end
end

defmodule Hr.JWTController do
  @moduledoc """
  The default implementation of JWTController. If you want to override
  it, either direct your routes to your own implementation (if you want to
  just override a couple of actions), or implement `YourApp.HrJWTController`
  with `use Hr.BaseJWTController`.
  """
  use Hr.BaseJWTController
end
