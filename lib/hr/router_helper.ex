defmodule Hr.RouterHelper do
  defmacro __using__(_) do
    quote do
      import Hr.RouterHelper
      import Hr.Plug
    end
  end

  @doc """
  hr_routes_for :comrade #, %{new_signup: %{path: "/anus/new"}} OR %{new_signup: %{helper: :"anus_signup", path: "/anus/new", controller: Hr.FormController, function: :new_signup, method: :get}}
  """
  defmacro hr_routes_for(entity, options \\ {:%{}, [line: 35], []}) do
    # helper, path, function, controller, method

    quote do
      for route <- default_routes(unquote(entity)) do
        {key, route} = route

        route =
        if Map.has_key? unquote(options), key do
          Map.merge route, unquote(options)[key]
        else
          route
        end

        case route.method do
          :post ->
            post route.path, route.controller, route.function, as: route.helper
          :get ->
            get route.path, route.controller, route.function, as: route.helper
          :put ->
            put route.path, route.controller, route.function, as: route.helper
          :delete ->
            delete route.path, route.controller, route.function, as: route.helper
        end
      end
    end
  end

  def default_routes(entity) do
    %{
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
  end
end
