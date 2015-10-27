defmodule Hr.RouterHelper do
  defmacro __using__(_) do
    quote do
      import Hr.RouterHelper
      import Hr.Plug
    end
  end

  @doc """
  hr_routes_for :comrade #, %{new_signup: %{path: "/anus/new"}} OR %{new_signup: %{helper: :"anus_signup", path: "/anus/new", controller: Hr.JWTController, function: :new_signup, method: :get}}
  """
  defmacro hr_jwt_routes_for(entity, options \\ {:%{}, [line: 35], []}) do
    # helper, path, function, controller, method

    # lol
    [_elixir, app, _router] = String.split(to_string(__CALLER__.module), ".")
    model = Module.concat(app, String.capitalize(to_string(entity)))

    quote do
      for route <- default_routes(unquote(entity), unquote(model.hr_behaviours), Hr.JWTController) do
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

  defmacro hr_routes_for(entity, options \\ {:%{}, [line: 35], []}) do
    # helper, path, function, controller, method

    # lol
    [_elixir, app, _router] = String.split(to_string(__CALLER__.module), ".")
    model = Module.concat(app, String.capitalize(to_string(entity)))

    quote do
      for route <- default_routes(unquote(entity), unquote(model.hr_behaviours)) do
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

  def default_routes(entity, behaviours, controller \\ Hr.FormController) do
    default = %{
      destroy_session: %{helper: :"#{entity}_session", path: "/#{entity}/logout", controller: controller, function: :destroy_session, method: :delete}
    }

    behaviour_routes = %{
      registerable: %{
        new_signup: %{helper: :"#{entity}_signup", path: "/#{entity}/new", controller: controller, function: :new_signup, method: :get},

        create_signup: %{helper: :"#{entity}_signup", path: "/#{entity}/new", controller: controller, function: :create_signup, method: :post}
      },
      confirmable: %{
        confirmation: %{helper: :"#{entity}_confirmation", path: "/#{entity}/confirmation", controller: controller, function: :confirmation, method: :get}
      },
      database_authenticatable: %{
        new_session: %{helper: :"#{entity}_session", path: "/#{entity}/login", controller: controller, function: :new_session, method: :get},

        create_session: %{helper: :"#{entity}_session", path: "/#{entity}/login", controller: controller, function: :create_session, method: :post}
      },
      oauthable: %{
        # generate helpers for each oauth provider?
        oauth_authorize: %{helper: :"#{entity}_oauth", path: "/#{entity}/oauth/:provider", controller: controller, function: :oauth_authorize, method: :get},

        oauth_callback: %{helper: :"#{entity}_oauth", path: "/#{entity}/oauth/:provider/callback", controller: controller, function: :oauth_callback, method: :get},
      },
      recoverable: %{
        new_password_reset_request: %{helper: :"#{entity}_password_reset_request", path: "/#{entity}/forgot", controller: controller, function: :new_password_reset_request, method: :get},

        create_password_reset_request: %{helper: :"#{entity}_password_reset_request", path: "/#{entity}/forgot", controller: controller, function: :create_password_reset_request, method: :post},

        new_password_reset: %{helper: :"#{entity}_password_reset", path: "/#{entity}/reset", controller: controller, function: :new_password_reset, method: :get},

        create_password_reset: %{helper: :"#{entity}_password_reset", path: "/#{entity}/reset", controller: controller, function: :create_password_reset, method: :post}
      },
      jwt_refreshable: %{
        create_refreshed_token: %{helper: :"#{entity}_token_refresh", path: "/#{entity}/refresh_token", controller: controller, function: :create_refreshed_token, method: :post}
      }
    }

    Enum.reduce(behaviours, default, fn(behaviour, acc) ->
      Map.merge(acc, behaviour_routes[behaviour])
    end)
  end
end
