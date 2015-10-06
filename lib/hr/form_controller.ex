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
        # changeset = @user.changeset(%{email: nil, password: nil})
        path = application.Router.Helpers.user_signup_path(conn, :create_signup)
        conn
        |> put_layout({application.LayoutView, :app})
        |> render("signup.html", user: application.User.__struct__, path: path)
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
