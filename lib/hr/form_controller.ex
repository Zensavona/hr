defmodule Hr.BaseFormController do
  @moduledoc """
   """
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller
      @repo Hr.Meta.repo
      @model String.to_atom(Hr.Meta.model_module)
      @identity Hr.Meta.identity_model

      @doc """
        Entry point for registering new users.
      """
      def new_signup(conn, _) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_signup_path")(conn, :create_signup)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("signup.html", changeset: @model.changeset(@model.__struct__), path: path)
      end

      def create_signup(conn, %{unquote(Hr.Meta.model) => params}) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_signup_path")(conn, :create_signup)


        {changeset, token} = Hr.Model.signup_changeset(@model.__struct__, params)
        case @repo.insert(changeset) do
          {:ok, user} ->
            link = Hr.Meta.confirmation_url(conn, user.id, token)
            Hr.MailHelper.send_confirmation_email(user, link)
            conn
            |> put_flash(:info, Hr.Messages.signed_up_but_unconfirmed)
            |> redirect(to: Hr.Meta.signed_up_url)
          {:error, changeset} ->
            conn
            |> put_layout({application.LayoutView, :app})
            |> render("signup.html", changeset: changeset, path: path)
        end
      end

      def new_confirmation(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
        user = @repo.get! @model, user_id
        changeset = Hr.Model.confirmation_changeset user, params

        if changeset.valid? do
          @repo.update!(changeset)
          conn
          |> put_flash(:info, "Email confirmed.")
          |> redirect(to: Hr.Meta.signed_up_url)
        else
          conn
          |> put_flash(:info, "That token has already been used.")
          |> redirect(to: Hr.Meta.signed_up_url)
        end
      end

      def new_session(conn, _) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_session_path")(conn, :create_session)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("session.html", changeset: @model.changeset(@model.__struct__), path: path)
      end

      def create_session(conn, %{unquote(Hr.Meta.model) => params}) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_session_path")(conn, :create_session)

        changeset = Hr.Model.session_changeset(@model.__struct__, params)
        case Hr.UserHelper.authenticate_with_email_and_password(conn, changeset) do
          {:ok, user} ->
            conn
            |> Hr.Session.login(user)
            |> put_flash(:info, Hr.Messages.signed_in_successfully)
            |> redirect(to: Hr.Meta.logged_in_url)
          {:error, _reason, conn} ->
            conn
            |> put_flash(:error, Hr.Messages.invalid_email_password)
            |> put_layout({application.LayoutView, :app})
            |> render("session.html", changeset: changeset, path: path)
        end
      end

      def destroy_session(conn, _) do
        conn
        |> Hr.Session.logout
        |> redirect(to: Hr.Meta.logged_out_url)
      end

      def oauth_authorize(conn, %{"provider" => provider}) do
        case Hr.Meta.valid_oauth_provider(provider) do
          true ->
            url = Hr.OAuth.Strategies.find(provider).authorize_url!
            redirect(conn, external: url)
          _ ->
            # error
        end
      end

      def oauth_callback(conn, %{"provider" => provider, "code" => code}) do
        case Hr.Meta.valid_oauth_provider(provider) do
          true ->
            strategy = Hr.OAuth.Strategies.find(provider)
            identity = strategy.get_identity!(strategy.get_token!(code: code))
            # if this OAuth id has a user associated with them,
            # log them in, else create one
            case Hr.UserHelper.authenticate_with_identity(identity) do
              {:ok, user} ->
                conn
                |> Hr.Session.login(user)
                |> put_flash(:info, Hr.Messages.signed_in_successfully)
                |> redirect(to: Hr.Meta.logged_in_url)
              {:error, _} ->
                user = Hr.UserHelper.create_with_identity(identity)
                conn
                |> Hr.Session.login(user)
                |> put_flash(:info, Hr.Messages.signed_in_successfully)
                |> redirect(to: Hr.Meta.logged_in_url)
            end
          _ ->
            # error
        end
      end

      def new_password_reset_request(conn, _) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_password_reset_request_path")(conn, :create_password_reset_request)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("password_reset_request.html", changeset: @model.changeset(@model.__struct__), path: path)
      end

      def create_password_reset_request(conn, %{unquote(Hr.Meta.model) => params}) do
        user = @repo.get_by! @model, email: params["email"]
        case user do
          nil ->
            nil
          user ->
            {changeset, token} = Hr.Model.reset_changeset(user)
            @repo.update!(changeset)
            link = Hr.Meta.reset_url(conn, user.id, token)
            Hr.MailHelper.send_reset_email(user, link)
        end
        conn
        |> put_flash(:info, "An email has been sent with further instructions.")
        |> redirect(to: Hr.Meta.signed_up_url)
      end

      def new_password_reset(conn, %{"id" => id, "password_reset_token" => token} = params) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_password_reset_path")(conn, :create_password_reset)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("password_reset.html", changeset: Ecto.Changeset.cast(@model.__struct__, %{id: id, password_reset_token: token}, ~w(id password_reset_token)), path: path)
      end

      def create_password_reset(conn, %{unquote(Hr.Meta.model) => params}) do
        application = Hr.Meta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.Meta.model}_password_reset_path")(conn, :create_password_reset)

        case Hr.UserHelper.get_with_id_and_token(params["id"], params["password_reset_token"]) do
          {:ok, user} ->
            changeset = Hr.Model.new_password_changeset(user, params)
            if changeset.valid? do
              @repo.update!(changeset)
              conn
              |> put_flash(:success, "Password reset successfully.")
              |> redirect(to: Hr.Meta.signed_up_url)
            else
              conn
              |> put_flash(:error, "Invalid password")
              |> put_layout({application.LayoutView, :app})
              |> render("password_reset.html", changeset: changeset, path: path)
            end
          {:error, _} ->
            conn
            |> put_flash(:error, "Invalid token.")
            |> redirect(to: Hr.Meta.signed_up_url)
        end
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end

defmodule Hr.FormController do
  use Hr.BaseFormController

end
