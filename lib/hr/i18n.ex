defmodule Hr.I18n do
  use Linguist.Vocabulary
  locale Hr.Meta.locale, Path.join([__DIR__, "../../priv/static/hr_locales/#{Hr.Meta.locale}.exs"])
end
