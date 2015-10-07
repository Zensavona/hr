defmodule Hr.Meta do

  def model do
    Mix.Phoenix.inflect(to_string(Application.get_env(:hr, :model)))[:singular]
  end

  def model_module do
    variations = Mix.Phoenix.inflect(to_string(Application.get_env(:hr, :model)))
    variations[:scoped] # get rid of the Elixir.?
  end

  def identity_model do
    variations = Mix.Phoenix.inflect(to_string(Application.get_env(:hr, :model)))
    [ _, app | _ ] = String.split(variations[:module], ".")

    Module.concat(app, "Identity")
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

  def locale do
    Application.get_env(:hr, :locale)
  end

  def repo do
    Application.get_env(:hr, :repo)
  end

  def logged_in_url do
    Application.get_env(:hr, :logged_in_url)
  end

  def not_logged_in_url do
    Application.get_env(:hr, :not_logged_in_url)
  end

  def logged_out_url do
    Application.get_env(:hr, :logged_out_url)
  end

  def signed_up_url do
    Application.get_env(:hr, :signed_up_url)
  end

  def register_from_email do
    Application.get_env(:hr, :register_from_email)
  end

  def password_recovery_from_email do
    Application.get_env(:hr, :password_recovery_from_email)
  end

  def oauth_strategies do
    Application.get_env(:hr, :oauth) || []
  end

  def valid_oauth_provider(provider) do
    Enum.member?(Hr.Meta.oauth_strategies, String.to_atom(provider))
  end

  def identity_model(conn) do
    Module.concat(app_name(conn), "Identity")
  end
end
