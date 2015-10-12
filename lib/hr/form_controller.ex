defmodule Hr.BaseFormController do
  @moduledoc """
   """
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller

      @doc """
      Display the login view and post the form to the next function
      """
      def new_session(conn, _) do
        {entity, model, repo, app} = Hr.Meta.stuff(conn)

        # BAM!
        path = apply(app.Router.Helpers, :"#{entity}_session_path", [app.Endpoint, :create_session])

        conn
        |> put_layout({app.LayoutView, :app})
        |> render("session.html", path: path)
      end

      @doc """
      Check if the submitted credentials are valid, if they are, create a session
      """
      def create_session(conn, %{"session" => %{"email" => email, "password" => password}}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(app.Router.Helpers, :"#{entity}_session_path", [app.Endpoint, :create_session])

        case Hr.UserHelper.authenticate_with_email_and_password(model, repo, email, password) do
          {:ok, user} ->
            conn
            |> Hr.Session.login(entity, user)
            |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "sessions.signed_in"))
            |> redirect(to: Hr.Meta.logged_in_url)
          {:error, _reason} ->
            conn
            |> put_flash(:error, Hr.I18n.t!(Hr.Meta.locale, "sessions.invalid"))
            |> put_layout({app.LayoutView, :app})
            |> render("session.html", path: path)
        end
      end

      @doc """
      Destroy the session
      """
      def destroy_session(conn, _) do
        conn
        |> Hr.Session.logout
        |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "sessions.signed_out"))
        |> redirect(to: Hr.Meta.logged_out_url)
      end

      @doc """
      redirect the user to the oauth provider's site so they can authenticate
      """
      def oauth_authorize(conn, %{"provider" => provider}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.Meta.valid_oauth_provider(provider) do
          true ->
            url = Hr.OAuth.Strategies.find(provider).authorize_url!(entity)
            redirect(conn, external: url)
          _ ->
            # error
        end
      end

      @doc """
      Try to look a user up by identity, if none exists, create one and log them in.
      """
      def oauth_callback(conn, %{"provider" => provider, "code" => code}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.Meta.valid_oauth_provider(provider) do
          true ->
            strategy = Hr.OAuth.Strategies.find(provider)
            identity = strategy.get_identity!(strategy.get_token!(entity, code: code))
            identity_model = :"#{model}Identity"
            # not a good idea to access the app inside the strategy anymore
            identity = struct(identity_model, identity)

            # if this OAuth id has a user associated with them,
            # log them in, else create one
            case Hr.UserHelper.authenticate_with_identity(repo, identity_model, entity, identity) do
              {:ok, user} ->
                conn
                |> Hr.Session.login(entity, user)
                |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "sessions.signed_in"))
                |> redirect(to: Hr.Meta.logged_in_url)
              {:error, _} ->
                user = Hr.UserHelper.create_with_identity(repo, identity_model, model, entity, identity)
                conn
                |> Hr.Session.login(entity, user)
                |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "registrations.signed_up"))
                |> redirect(to: Hr.Meta.logged_in_url)
            end
          _ ->
            # error
        end
      end

      @doc """
      Display the signup form and post to the next function
      """
      def new_signup(conn, _) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(app.Router.Helpers, :"#{entity}_signup_path", [app.Endpoint, :create_signup])

        conn
        |> put_layout({app.LayoutView, :app})
        |> render("signup.html", changeset: model.changeset(model.__struct__), path: path)
      end

      @doc """
      Create a new user if the email address isn't already taken.
      """
      def create_signup(conn, data) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(app.Router.Helpers, :"#{entity}_signup_path", [app.Endpoint, :create_signup])

        params = data[entity]
        {changeset, token} = Hr.Model.signup_changeset(model.__struct__, params)
        case repo.insert(changeset) do
          {:ok, user} ->
            link = Hr.Meta.confirmation_url(conn, user.id, token)
            Hr.MailHelper.send_confirmation_email(user, link)
            conn
            |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "registrations.signed_up_but_unconfirmed", email: user.unconfirmed_email))
            |> redirect(to: Hr.Meta.signed_up_url)
          {:error, changeset} ->
            conn
            |> put_layout({app.LayoutView, :app})
            |> render("signup.html", changeset: changeset, path: path)
        end
      end

      @doc """
      Confirms the email for the user
      """
      def confirmation(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        user = repo.get! model, user_id
        changeset = Hr.Model.confirmation_changeset user, params

        if changeset.valid? do
          repo.update!(changeset)
          conn
          |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "registrations.confirmed"))
          |> redirect(to: Hr.Meta.signed_up_url)
        else
          conn
          |> put_flash(:error, Hr.I18n.t!(Hr.Meta.locale, "registrations.invalid_confirmation_token"))
          |> redirect(to: Hr.Meta.signed_up_url)
        end
      end

      @doc """
      Captures the email address to send a password reset link to
      """
      def new_password_reset_request(conn, _) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(app.Router.Helpers, :"#{entity}_password_reset_request_path", [app.Endpoint, :create_password_reset_request])

        conn
        |> put_layout({app.LayoutView, :app})
        |> render("password_reset_request.html", path: path)
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
            Hr.MailHelper.send_reset_email(user, link)
        end
        conn
        |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "passwords.send_instructions"))
        |> redirect(to: Hr.Meta.signed_up_url)
      end

      @doc """
      capture the requested new password from the user
      """
      def new_password_reset(conn, %{"id" => id, "password_reset_token" => token}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(app.Router.Helpers, :"#{entity}_password_reset_path", [app.Endpoint, :new_password_reset])

        conn
        |> put_layout({app.LayoutView, :app})
        |> render("password_reset.html", id: id, token: token, path: path)
      end

      @doc """
      Reset the user's password
      """
      def create_password_reset(conn, %{"reset" => params}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(app.Router.Helpers, :"#{entity}_password_reset_path", [app.Endpoint, :create_password_reset])

        case Hr.UserHelper.get_with_id_and_token(repo, model, params["id"], params["password_reset_token"]) do
          {:ok, user} ->
            changeset = Hr.Model.new_password_changeset(user, params)
            if changeset.valid? do
              repo.update!(changeset)
              conn
              |> put_flash(:info, Hr.I18n.t!(Hr.Meta.locale, "passwords.updated"))
              |> redirect(to: Hr.Meta.signed_up_url)
            else
              conn
              |> put_layout({app.LayoutView, :app})
              |> put_flash(:error, Hr.I18n.t!(Hr.Meta.locale, "passwords.invalid"))
              |> render("password_reset.html", changeset: changeset, id: params["id"], token: params["password_reset_token"], path: path)
            end
          {:error, _} ->
            conn
            |> put_flash(:error, Hr.I18n.t!(Hr.Meta.locale, "passwords.no_token"))
            |> redirect(to: Hr.Meta.signed_up_url)
        end
      end
    end
  end
end

defmodule Hr.FormController do
  use Hr.BaseFormController
end
