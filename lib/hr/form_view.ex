defmodule Hr.BaseFormView do
  defmacro __using__(_) do
    quote do
      use Phoenix.View, root: "priv/templates/html"
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]
      use Phoenix.HTML
      # import HrDemo.Router.Helpers
    end
  end
end

defmodule Hr.FormView do
   use Hr.BaseFormView
end
