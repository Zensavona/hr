defmodule Hr.BaseI18n do
  defmacro __using__(dir) do
    quote do
      use Linguist.Vocabulary
      locale Hr.Meta.locale, unquote(dir) <> "#{Hr.Meta.locale}.exs"
    end
  end
end

defmodule Hr.I18n do
   use Hr.BaseI18n, "priv/static/hr_locales/"
end
