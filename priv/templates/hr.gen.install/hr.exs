use Mix.Config

config :hr, locale: "en",
            logged_in_url: "/",
            not_logged_in_url: "/error",
            logged_out_url: "/",
            signed_up_url: "/",
            register_from_email: "Registration <welcome@example.com>",
            password_recovery_from_email: "Password Recovery <no-reply@example.com>",
            confirmation_email_subject: "Confirm Your Account",
            recovery_email_subject: "Reset Your Password",
            mailgun_domain: "https://api.mailgun.net/v3/mydomain.com",
            mailgun_key: "key-##############",
            mailgun_mode: :test, # or :production to actually send real emails
            mailgun_test_file_path: "/tmp/mail.json"

            # Example OAuth config:
            # oauth: [:github],
            # github_client_id: "XXXXXXXXX",
            # github_client_secret: "XXXXXXXXXXXXXXXXXXXXX"
