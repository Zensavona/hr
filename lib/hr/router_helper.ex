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
      new_signup: %{helper: :"new_#{entity}_signup", path: "/#{entity}/new", controller: Hr.AccountsController, function: :new_signup, method: :get},

      create_signup: %{helper: :"create_#{entity}_signup", path: "/#{entity}/new", controller: Hr.AccountsController, function: :create_signup, method: :post},

      new_session: %{helper: :"new_#{entity}_session", path: "/login", controller: Hr.SessionController, function: :new_session, method: :get},

      create_session: %{helper: :"create_#{entity}_session", path: "/login", controller: Hr.SessionController, function: :new_session, method: :post}
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

  defmacro hr(:route_s, options \\ %{}) do
    name = Hr.Meta.model

    # routes = [
    #             [:"new_#{name}_signup", :new_signup, :get],
    #             [:"#{name}_signup", :create_signup, :post],
    #             [:"new_#{name}_session", :new_session, :get],
    #             [:"#{name}_session", :create_session, :post],
    #             [:"destroy_#{name}_session", :destroy_session, :delete],
    #             [:"#{name}_oauth_authorize/:provider", :oauth_authorize, :get],
    #             [:"#{name}_oauth_callback/:provider", :oauth_callback, :get],
    #             [:"new_#{name}_confirmation", :new_confirmation, :get],
    #             [:"#{name}_confirmation", :create_confirmation, :post],
    #             [:"new_#{name}_password_reset", :new_password_reset, :get],
    #             [:"#{name}_password_reset", :create_password_reset, :post]
    #          ]

    routes = [
                 [:"new_#{name}_signup", :new_signup, :get],
                 [:"#{name}_signup", :create_signup, :post],
                 [:"new_#{name}_session", :new_session, :get],
                 [:"#{name}_session", :create_session, :post],
                 [:"destroy_#{name}_session", :destroy_session, :delete],
                 [:"#{name}_oauth_authorize/:provider", :oauth_authorize, :get],
                 [:"#{name}_oauth_callback/:provider", :oauth_callback, :get],
                 [:"new_#{name}_confirmation", :new_confirmation, :get],
                 [:"#{name}_confirmation", :create_confirmation, :post],
                 [:"new_#{name}_password_reset_request", :new_password_reset_request, :get],
                 [:"#{name}_password_reset_request", :create_password_reset_request, :post],
                 [:"new_#{name}_password_reset", :new_password_reset, :get],
                 [:"#{name}_password_reset", :create_password_reset, :post]
              ]



    for route <- routes do
      [name, action, method] = route
      # get the param from the route if it exists
      parts = name |> to_string |> String.split("/:")
      route_options = options_for_route(parts, options[route])

      quote do
        unquote(method)(unquote(route_options[:path]),
          unquote(route_options[:controller]),
          unquote(action),
          as: unquote(route_options[:as]))
      end
    end
  end

  defp options_for_route(route, options) when is_list(options) do
    path = if is_list(route), do: Enum.join(route, "/:"), else: List.first(route)
    route = List.first(route)

    path       = route_path(path, options[:path])
    controller = options[:controller] || Hr.FormController
    action     = options[:action] || route
    as         = route

    %{path: path, controller: controller, action: action, as: as}
  end
  defp options_for_route(route, path) do
    options_for_route(route, [path: route_path(route, path)])
  end

  defp route_path(route, path) do
    route = if is_list(route), do: Enum.join(route, "/:"), else: route
    path || "/#{to_string(route)}"
  end
end
