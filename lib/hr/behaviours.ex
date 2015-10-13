defmodule Hr.Behaviours do
  defmacro __using__(list) do
    quote do
      def hr_behaviours do
        unquote(list)
      end
    end
  end
end
