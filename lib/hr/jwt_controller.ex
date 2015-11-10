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

        case model.get_with_credentials(email, password) do
          nil ->
            conn
            |> put_status(:unauthorized)
            |> render("error.json", errors: ["Invalid credentials"])
          user ->
            token = Hr.JWT.create(conn, entity, user)
            response = %{token: token, entity: user}
            conn |> json(response)
        end
      end

      @doc """
      Create a new user if the email address isn't already taken.
      """
      def create_signup(conn, params) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case model.confirmable? do
          true ->
            {changeset, token} = model.confirmable_signup_changeset(params)
            case model.repo.insert(changeset) do
              {:ok, user} ->
                user = model.repo.update!(model.unconfirm_email(user))
                link = Hr.Meta.confirmation_url(conn, user.id, token)
                Hr.Meta.mailer(app).send_confirmation_email(user, link)
                conn |> render("generic_flash.json", flash: Hr.Meta.i18n("registrations.signed_up_but_unconfirmed", email: user.unconfirmed_email))
              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render("error.json", errors: changeset)
            end
          _ ->
            changeset = model.signup_changeset(params)
            case model.repo.insert(changeset) do
              {:ok, user} ->
                token = Hr.JWT.create(conn, entity, user)
                user = user |> model.get_for_me |> model.repo.one
                IO.inspect user
                json(conn, %{token: token, entity: user})
              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render("error.json", errors: changeset)
            end
        end
      end

      @doc """
      Confirms the email for the user
      """
      def confirmation(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case model.repo.get(model, user_id) do
          nil ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", errors: ["Something went wrong"])
          user ->
            changeset = model.confirmation_changeset(user, params)
            case model.repo.update(changeset) do
              {:ok, _} ->
                conn
                |> render("generic_flash.json", flash: Hr.Meta.i18n("confirmations.confirmed"))
              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render("error.json", errors: changeset)
            end
        end
      end

      @doc """
      If the email exists, send a reset link
      """
      def create_password_reset_request(conn, %{"reset" => %{"email" => email}}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        user = repo.get_by! model, email: email

        case model.repo.get_by(model, email: email) do
          nil ->
            nil
          user ->
            {changeset, token} = model.reset_changeset(user)
            repo.update!(changeset)
            link = Hr.Meta.reset_url(conn, user.id, token)
            Hr.Meta.mailer(app).send_reset_email(user, link)
        end
        render(conn, "generic_flash.json", flash: Hr.Meta.i18n("passwords.send_instructions"))
      end

      @doc """
      Reset the user's password
      """
      def create_password_reset(conn, %{"reset" => params}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case model.get_with_id_and_token(params["id"], params["password_reset_token"]) do
          {:ok, user} ->
            changeset = model.new_password_changeset(user, params)
            case model.repo.update(changeset) do
              {:ok, _} ->
                render(conn, "generic_flash.json", flash: Hr.Meta.i18n("passwords.updated"))
              {:error, changeset} ->
                conn
                |> put_status(:unauthorized)
                |> render("error.json", errors: changeset)
            end
          {:error, _} ->
            conn
            |> put_status(:unauthorized)
            |> render("error.json", errors: Hr.Meta.i18n("passwords.no_token"))
        end
      end

      def create_refreshed_token(conn, %{"token" => token}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.JWT.refresh(conn, token) do
          {:ok, fresh} ->
            render(conn, "authenticate.json", token: fresh)
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
