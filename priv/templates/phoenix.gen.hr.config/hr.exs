use Mix.Config

config :hr, locale: :en,
            model: <%= module %>,
            repo: <%= repo %>,
            logged_in_url: "/",
            not_logged_in_url: "/error",
            logged_out_url: "/",
            signed_up_url: "/",
            register_from_email: "Registration <welcome@yourawesomeapp.com>",
            password_recovery_from_email: "Password Recovery <no-reply@yourawesomeapp.com>"
