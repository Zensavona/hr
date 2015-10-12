defmodule Hr.RouterHelper do
  defmacro __using__(_) do
    quote do
      import Hr.RouterHelper
      import Hr.Plug
    end
  end

  defmacro hr_routes_for(entity, options \\ %{}) do
    # helper, path, function, controller, method
    routes = %{
      new_signup: %{helper: :"#{entity}_signup", path: "/#{entity}/new", controller: Hr.FormController, function: :new_signup, method: :get},

      create_signup: %{helper: :"#{entity}_signup", path: "/#{entity}/new", controller: Hr.FormController, function: :create_signup, method: :post},

      new_session: %{helper: :"#{entity}_session", path: "/#{entity}/login", controller: Hr.FormController, function: :new_session, method: :get},

      create_session: %{helper: :"#{entity}_session", path: "/#{entity}/login", controller: Hr.FormController, function: :create_session, method: :post},

      # generate helpers for each oauth provider?
      oauth_authorize: %{helper: :"#{entity}_oauth", path: "/#{entity}/oauth/:provider", controller: Hr.FormController, function: :oauth_authorize, method: :get},

      oauth_callback: %{helper: :"#{entity}_oauth", path: "/#{entity}/oauth/:provider/callback", controller: Hr.FormController, function: :oauth_callback, method: :get},

      destroy_session: %{helper: :"#{entity}_session", path: "/#{entity}/logout", controller: Hr.FormController, function: :destroy_session, method: :delete},

      confirmation: %{helper: :"#{entity}_confirmation", path: "/#{entity}/confirmation", controller: Hr.FormController, function: :confirmation, method: :get},

      new_password_reset_request: %{helper: :"#{entity}_password_reset_request", path: "/#{entity}/forgot", controller: Hr.FormController, function: :new_password_reset_request, method: :get},

      create_password_reset_request: %{helper: :"#{entity}_password_reset_request", path: "/#{entity}/forgot", controller: Hr.FormController, function: :create_password_reset_request, method: :post},

      new_password_reset: %{helper: :"#{entity}_password_reset", path: "/#{entity}/reset", controller: Hr.FormController, function: :new_password_reset, method: :get},

      create_password_reset: %{helper: :"#{entity}_password_reset", path: "/#{entity}/reset", controller: Hr.FormController, function: :create_password_reset, method: :post}
    }

    for route <- routes do
      {_, route} = route

      quote do
        unquote(route.method)(unquote(route.path),
          unquote(route.controller),
          unquote(route.function),
          as: unquote(route.helper))
      end
    end
  end
end
