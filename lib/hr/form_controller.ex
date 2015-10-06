defmodule Hr.BaseFormController do
  @moduledoc """
   """

  defmacro __using__(_) do
    quote do
      use Phoenix.Controller
      @user Application.get_env(:hr, :model)

      @doc """
        Entry point for registering new users.
      """
      def new_signup(conn, _) do
        application = Hr.ApplicationMeta.app_name(conn)
        model = unquote(String.to_atom(Hr.ApplicationMeta.model_module))
        changeset = model.changeset(model.__struct__)
        path = application.Router.Helpers.unquote(:"#{Hr.ApplicationMeta.model_name}_signup_path")(conn, :create_signup)

        conn
        |> put_layout({application.LayoutView, :app})
        |> render("signup.html", user: changeset, path: path)
      end

      # def create_signup(conn, user_params) do
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
