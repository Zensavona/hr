defmodule Mix.Tasks.Phoenix.Gen.Hr.Install do
  use Mix.Task

  @shortdoc "Generates HR's config file and migrations"

  def run(args) do

    if length(args) != 1 || length(Regex.run(~r/^[A-z]+$/i, List.first(args))) != 1 do
      raise_with_help
    end

    name = List.first(args)

    variations = Mix.Phoenix.inflect(name)
    name =  Module.concat(Elixir, variations[:module])

    if !Code.ensure_loaded?(name) do
      raise_with_help
    end

    files = [
      {:eex, "hr.exs", "config/hr.exs"}
    ]

    Mix.Phoenix.copy_from paths(), "priv/templates/phoenix.gen.hr.config", "", variations, files

    Mix.shell.info """

    ======================================================================

                    .----------------. .----------------.
                  | .--------------. | .--------------. |
                  | |  ____  ____  | | |  _______     | |
                  | | |_   ||   _| | | | |_   __  \   | |
                  | |   | |__| |   | | |   | |__) |   | |
                  | |   |  __  |   | | |   |  __ /    | |
                  | |  _| |  | |_  | | |  _| |  \ \_  | |
                  | | |____||____| | | | |____| |___| | |
                  | |              | | |              | |
                  | '--------------' | '--------------' |
                  '----------------' '----------------'

    Congratulations on your fine choice of authentication library, friend.


    Instructions:
        1. add the following line to the end of your config/config.exs:

                      --> import_config "hr.exs" <--

        2. run the migration/s with `mix ecto.migrate`
        3. Enjoy your easy life of not writing dumb authentication code <3
    ======================================================================
    """
  end

  defp raise_with_help do
    Mix.raise """


    mix phoenix.gen.hr.install expects an argument which is a valid model name
    to configure HR to use, for example:
                                          mix phoenix.gen.hr.install User

    If you haven't yet run `mix phoenix.gen.hr.model`, please do so before running
    this task.
    """
  end

  defp paths do
    [".", :hr]
  end
end
