defmodule Hr.Meta do

  def stuff(conn) do
    entity = to_string(conn.private.hr_entity)
    variations = Mix.Phoenix.inflect(entity)
    app = String.to_atom(app_name(conn))
    model = Module.concat(app, variations[:scoped])
    repo = Module.concat(app, "Repo")

    {entity, model, repo, app}
  end

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
    Application.get_env(:hr, :locale) || "en"
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

  def confirmation_url(conn, id, token) do
    {entity, _model, _repo, app} = stuff(conn)
    path = apply(app.Router.Helpers, :"#{entity}_confirmation_url", [app.Endpoint, :confirmation])

    path <> "?id=#{id}&confirmation_token=#{token}"
  end

  def reset_url(conn, id, token) do
    {entity, _model, _repo, app} = stuff(conn)
    path = apply(app.Router.Helpers, :"#{entity}_password_reset_url", [app.Endpoint, :create_password_reset])

    path <> "?id=#{id}&password_reset_token=#{token}"
  end

  def form_view(app) do
    if Code.ensure_loaded? app.HrFormView do
      app.HrFormView
    else
      Hr.FormView
    end
  end

  def i18n(app, message) do
    if Code.ensure_loaded? app.HrI18n do
      app.HrI18n.t!(Hr.Meta.locale, message)
    else
      Hr.I18n.t!(Hr.Meta.locale, message)
    end
  end

  def i18n(app, message, bindings) do
    if Code.ensure_loaded? app.HrI18n do
      app.HrI18n.t!(Hr.Meta.locale, message, bindings)
    else
      Hr.I18n.t!(Hr.Meta.locale, message, bindings)
    end
  end

  def mailer(app) do
    if Code.ensure_loaded? app.HrMailHelper do
      app.HrMailHelper
    else
      Hr.MailHelper
    end
  end
end
