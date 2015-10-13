defmodule Mix.Tasks.Hr.Install do
  use Mix.Task

  @shortdoc "Generates HR's config file and migrations"

  def run(_) do

    name = "HR"

    variations = Mix.Phoenix.inflect(name)

    files = [
      {:eex, "hr.exs", "config/hr.exs"}
    ]

    Mix.Phoenix.copy_from paths(), "priv/templates/hr.gen.install", "", variations, files


    logo = """
                .----------------.   .----------------.
               | .--------------. | | .--------------. |
               | |  ____  ____  | | | |  _______     | |
               | | |_   ||   _| | | | | |_   __ \\    | |
               | |   | |__| |   | | | |   | |__) |   | |
               | |   |  __  |   | | | |   |  __ /    | |
               | |  _| |  | |_  | | | |  _| |  \\ \\_  | |
               | | |____||____| | | | | |____| |___| | |
               | |              | | | |              | |
               | '--------------' | | '--------------' |
                '----------------'   '----------------'
    """

    heart = IO.ANSI.format([:magenta, :bright, "<3"], true)
    file = IO.ANSI.format([:green, :bright, "import_config \"hr.exs\""], true)
    logo = IO.ANSI.format([:magenta, :bright, logo], true)

    Mix.shell.info """

    ======================================================================

    #{logo}

      Congrats on your fine choice of authentication library, friend.


      Instructions:
        1. add the following line to the end of your config/config.exs:

                      --> #{file} <--

        2. run `mix hr.gen.model [Singluar] [plural]` if you haven't
           already (or follow the instructions to add HR to an existing
           Model)
        3. Enjoy your easy life of not writing dumb authentication code #{heart}
    ======================================================================
    """
  end

  defp paths do
    [".", :hr]
  end
end
