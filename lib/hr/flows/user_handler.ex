defmodule Hr.BaseUserHandler do
  @moduledoc """
  """


  defmacro __using__(_) do
    quote do
      # def create(user_params, repo \\ Addict.Repository, mailer \\ Addict.EmailGateway, # password_interactor \\ Addict.PasswordInteractor) do
      #   validate_params(user_params)
      #   |> (fn (params) -> params["password"] end).()
      #   |> password_interactor.generate_hash
      #   |> create_username(user_params, repo)
      #   |> send_welcome_email(mailer)
      # end
    end
  end
end

defmodule Hr.UserHandler do
  use Hr.BaseUserHandler
end
