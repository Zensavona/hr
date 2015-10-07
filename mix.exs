defmodule Hr.Mixfile do
  use Mix.Project

  def project do
    [app: :hr,
     version: "0.0.1",
     elixir: "~> 1.0",
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :phoenix, :phoenix_html, :oauth2]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:phoenix, "~> 1.0"},
      {:phoenix_html, "~> 2.1"},
      {:phoenix_ecto, "~> 1.1"},
      {:yomel, "~> 0.2.2"},
      {:plug, "~> 1.0"},
      {:comeonin, "~> 1.0"},
      {:oauth2, "~> 0.3.0"},
      {:yyid, "~> 0.1"},
      {:mailgun, "~> 0.1.2"}
    ]
  end
end
