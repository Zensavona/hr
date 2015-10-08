defmodule Hr.BaseSessionController do
  @moduledoc """
   """
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller

      def new_session(conn, _) do
        {entity, model, repo, app} = Hr.Meta.stuff(conn)
        entity = to_string(conn.private.hr_entity)

        path = app.Router.Helpers.unquote(conn.private.hr_entity)(conn, :create_session)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("session.html", path: path)
      end

      def create_session(conn, %{"session" => %{"email" => email, "password" => password}}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = app.Router.Helpers.unquote(:"create_#{entity}_session_path")(conn, :create_session)

        case Hr.UserHelper.authenticate_with_email_and_password(model, repo, email, password) do
          {:ok, user} ->
            conn
            |> Hr.Session.login(entity, user)
            |> put_flash(:info, Hr.Messages.signed_in_successfully)
            |> redirect(to: Hr.Meta.logged_in_url)
          {:error, _reason, conn} ->
            conn
            |> put_flash(:error, Hr.Messages.invalid_email_password)
            |> put_layout({application.LayoutView, :app})
            |> render("session.html", path: path)
        end
      end
    end
  end
end

defmodule Hr.SessionController do
  use Hr.BaseSessionController
end
