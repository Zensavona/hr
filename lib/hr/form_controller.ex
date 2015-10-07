defmodule Hr.BaseFormController do
  @moduledoc """
   """

  defmacro __using__(_) do
    quote do
      use Phoenix.Controller

      @model unquote(String.to_atom(Hr.Meta.model_module))

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

        changeset = Hr.Model.signup_changeset(@model.__struct__, params)

        case Hr.Repo.insert(changeset) do
          {:ok, user} ->
            conn
            |> Hr.Session.login(user)
            |> put_flash(:info, Hr.Messages.signed_up_but_unconfirmed)
            |> redirect(to: Hr.Meta.signed_up_url)
          {:error, changeset} ->
            conn
            |> put_layout({application.LayoutView, :app})
            |> render("signup.html", changeset: changeset, path: path)
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

        case Hr.Session.authenticate_with_email_and_password(conn, changeset) do
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

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end

defmodule Hr.FormController do
  use Hr.BaseFormController

end
