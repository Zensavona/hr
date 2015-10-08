defmodule Hr.MailHelper do
  use Mailgun.Client, domain: Application.get_env(:hr, :mailgun_domain),
                     key: Application.get_env(:hr, :mailgun_key),
                     mode: Application.get_env(:hr, :mailgun_mode),
                     test_file_path: Application.get_env(:hr, :mailgun_test_file_path)

  @path "web/templates/emails/"

  def send_confirmation_email(user, link) do
    send_email to: user.unconfirmed_email,
               from: Application.get_env(:hr, :register_from_email),
               subject: "hello!",
               html: EEx.eval_file(@path <> "signup_confirmation.eex", [user: user, link: link])
  end

  def send_reset_email(user, link) do
    send_email to: user.unconfirmed_email,
               from: Application.get_env(:hr, :password_recovery_from_email),
               subject: "hello!",
               html: EEx.eval_file(@path <> "password_reset.eex", [user: user, link: link])
  end
end
