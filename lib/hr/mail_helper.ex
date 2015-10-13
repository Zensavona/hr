defmodule Hr.BaseMailHelper do
  defmacro __using__(dir) do
    quote do
      use Mailgun.Client, domain: Application.get_env(:hr, :mailgun_domain),
                         key: Application.get_env(:hr, :mailgun_key),
                         mode: Application.get_env(:hr, :mailgun_mode),
                         test_file_path: Application.get_env(:hr, :mailgun_test_file_path)

      def send_confirmation_email(user, link) do
        send_email to: user.unconfirmed_email,
                   from: Application.get_env(:hr, :register_from_email),
                   subject: Application.get_env(:hr, :confirmation_email_subject),
                   html: EEx.eval_file(unquote(dir) <> "signup_confirmation.eex", [user: user, link: link])
      end

      def send_reset_email(user, link) do
        send_email to: user.email,
                   from: Application.get_env(:hr, :password_recovery_from_email),
                   subject: Application.get_env(:hr, :recovery_email_subject),
                   html: EEx.eval_file(unquote(dir) <> "password_reset.eex", [user: user, link: link])
      end
    end
  end
end

defmodule Hr.MailHelper do
  use Hr.BaseMailHelper, "web/templates/hr_email/"
end
