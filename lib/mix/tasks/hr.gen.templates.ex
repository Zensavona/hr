defmodule Mix.Tasks.Hr.Gen.Templates do
  @moduledoc """
  Generates default templates into the parent application's
  `web/template/hr_form` directory, customise them there.
  """
  use Mix.Task

  @shortdoc "Generates HR templates for you to customise"

  @doc """
  Run the mix task and generate some stuff
  """
  def run(_) do
    base = Mix.Phoenix.base

    files = [
      {:eex, "hr_form_view.ex", "web/views/hr_form_view.ex"},
      {:text, "session.html.eex", "web/templates/hr_form/session.html.eex"},
      {:text, "signup.html.eex", "web/templates/hr_form/signup.html.eex"},
      {:text, "password_reset_request.html.eex", "web/templates/hr_form/password_reset_request.html.eex"},
      {:text, "password_reset.html.eex", "web/templates/hr_form/password_reset.html.eex"}
    ]

    Mix.Phoenix.copy_from paths(), "priv/templates/html/form", "", [base: base], files

    heart = IO.ANSI.format([:magenta, :bright, "<3"], true)

    Mix.shell.info """

    ======================================================================

      Templates have been generated, you can edit them to customise the
      look and feel of your app.

        #{green_bullet_point("web/views/hr_form_view.ex")}
        #{green_bullet_point("web/templates/hr_form/session.html.eex")}
        #{green_bullet_point("web/templates/hr_form/signup.html.eex")}
        #{green_bullet_point("web/templates/hr_form/password_reset_request.html.eex")}
        #{green_bullet_point("web/templates/hr_form/password_reset.html.eex")}

                                  #{heart}
    ======================================================================
    """
  end

  defp green_bullet_point(msg) do
    IO.ANSI.format([:green, :bright, "* #{msg}"], true)
  end

  defp paths do
    [".", :hr]
  end
end
