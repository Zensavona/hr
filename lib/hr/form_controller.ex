defmodule Hr.BaseFormController do
  @moduledoc """
   """

  defmacro __using__(_) do
    quote do
      use Phoenix.Controller

      @model unquote(String.to_atom(Hr.Meta.model_module))
      @repo Hr.Meta.repo
      @signed_up_url Application.get_env(:hr, :signed_up_url)

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
        IO.inspect changeset

        case @repo.insert(changeset) do
          {:ok, user} ->
            conn
            # login |> Rumbl.Auth.login(user)
            |> put_flash(:info, Hr.Messages.signed_up_but_unconfirmed)
            |> redirect(to: @signed_up_url)
          {:error, changeset} ->
            conn
            |> put_layout({application.LayoutView, :app})
            |> render("signup.html", changeset: changeset, path: path)
        end
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end

defmodule Hr.FormController do
  use Hr.BaseFormController

end
