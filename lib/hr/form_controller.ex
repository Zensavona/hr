defmodule Hr.BaseFormController do
  @moduledoc """
   """

  defmacro __using__(_) do
    quote do
      use Phoenix.Controller

      @model unquote(String.to_atom(Hr.ApplicationMeta.model_module))
      @repo Application.get_env(:hr, :repo)

      @doc """
        Entry point for registering new users.
      """
      def new_signup(conn, _) do
        application = Hr.ApplicationMeta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.ApplicationMeta.model_name}_signup_path")(conn, :create_signup)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("signup.html", changeset: @model.changeset(@model.__struct__), path: path)
      end

      def create_signup(conn, %{unquote(Hr.ApplicationMeta.model_name) => params}) do
        application = Hr.ApplicationMeta.app_name(conn)
        path = application.Router.Helpers.unquote(:"#{Hr.ApplicationMeta.model_name}_signup_path")(conn, :create_signup)

        changeset = Hr.Model.signup_changeset(@model.__struct__, params)
        IO.inspect changeset

        case @repo.insert(changeset) do
          {:ok, user} ->
            IO.inspect user
            # conn
            #   |> Rumbl.Auth.login(user)
            #   |> put_flash(:info, "#{user.name} created!")
            #   |> redirect(to: user_path(conn, :index))
          {:error, changeset} ->
            conn
            |> put_layout({application.LayoutView, :app})
            |> render("signup.html", changeset: changeset, path: path)
        end
      end

      # def create_signup(conn, params) do
      #   {conn, message} = Hr.UserHandler.create(user_params) |> SessionInteractor.register(conn)
      #   json conn, message
      # end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end

defmodule Hr.FormController do
  use Hr.BaseFormController

end
