defmodule Hr.Mixfile do
  use Mix.Project

  def project do
    [app: :hr,
     version: "0.2.2",
     elixir: "~> 1.0",
     compilers: [:phoenix] ++ Mix.compilers,
     test_coverage: [tool: ExCoveralls],
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :phoenix, :phoenix_html, :oauth2,
                    :phoenix_ecto, :plug, :comeonin, :yyid,
                    :mailgun, :linguist, :joken]]
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
      {:plug, "~> 1.0"},
      {:comeonin, "~> 1.3.1"},
      {:oauth2, "~> 0.3.0"},
      {:yyid, "~> 0.1"},
      {:mailgun, git: "https://github.com/Zensavona/mailgun.git", branch: "fix_config"},
      {:linguist, "~> 0.1.5"},
      {:joken, "~> 0.16.1"},
      {:ex_doc, "~> 0.10.0", only: [:dev, :docs]},
      {:excoveralls, "~> 0.3", only: [:dev, :test]},
      {:inch_ex, "~> 0.4.0", only: [:dev, :docs]}
    ]
  end

  defp description do
    """
    User accounts for Phoenix. Supports OAuth, JWT and forms out of the box
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      keywords: ["Elixir", "Phoenix", "accounts", "authorisation", "authorization", "HTTP", "JWT", "Forms", "sessions", "users", "devise", "token"],
      maintainers: ["Zen Savona"],
      links: %{"GitHub" => "https://github.com/zensavona/hr",
               "Docs" => "https://hexdocs.pm/hr"}
    ]
  end
end
