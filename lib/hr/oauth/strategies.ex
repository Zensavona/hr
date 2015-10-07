defmodule Hr.OAuth.Strategies do
  def find(provider) do
    strategies = %{
                    github: Hr.OAuth.GitHub
                  }

    strategies[String.to_atom(provider)]
  end
end
