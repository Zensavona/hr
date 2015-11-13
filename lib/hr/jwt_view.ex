defmodule Hr.BaseJWTView do
  defmacro __using__(dir) do
    quote do
      use Phoenix.View, root: unquote(dir)
    end
  end
end

defmodule Hr.JWTView do
  use Hr.BaseFormView, "priv/templates/html"

  def render("authenticate.json", map) do
    map
  end

  def render("generic_flash.json", %{flash: message}) do
    %{flash: message}
  end

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
