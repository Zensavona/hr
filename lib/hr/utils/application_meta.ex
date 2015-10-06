defmodule Hr.ApplicationMeta do
  def application_name(conn) do
    Mix.Phoenix.inflect("#{conn.private.phoenix_endpoint}")[:base]
  end

  def model_name do
    Mix.Phoenix.inflect(to_string(Application.get_env(:hr, :model)))[:singular]
  end

  def app_name do
    Mix.Phoenix.inflect(to_string(Application.get_env(:hr, :model)))[:base]
  end

  def model_module do
    variations = Mix.Phoenix.inflect(to_string(Application.get_env(:hr, :model)))
    variations[:scoped] # get rid of the Elixir.?
  end

  def app_name(conn) do
    conn.private.phoenix_endpoint.config(:otp_app)
    |> to_string
    |> Mix.Utils.camelize
  end

  def app_module do
    Mix.Project.config()[:app]
    |> Atom.to_string
    |> Mix.Utils.camelize
  end
end
