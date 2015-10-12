defmodule Hr.OAuth.GitHub do
  use OAuth2.Strategy

  # Public API

  def new_for_entity(entity) do
    OAuth2.new([
      strategy: __MODULE__,
      client_id: Application.get_env(:hr, :github_client_id) || System.get_env("GITHUB_CLIENT_ID"),
      client_secret: Application.get_env(:hr, :github_client_secret) || System.get_env("GITHUB_CLIENT_SECRET"),
      redirect_uri: "http://localhost:4000/#{entity}/oauth/github/callback",
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
  end

  def authorize_url!(entity, params \\ []) do
    new_for_entity(entity)
    |> put_param(:scope, "user")
    |> OAuth2.Client.authorize_url!(params)
  end

  # you can pass options to the underlying http library via `options` parameter
  def get_token!(entity, params \\ [], headers \\ [], options \\ []) do
    OAuth2.Client.get_token!(new_for_entity(entity), params, headers, options)
  end

  def get_identity!(token) do
    user = OAuth2.AccessToken.get!(token, "/user")
    name = String.split(user["name"], " ") || [user["name"]]
    identity = %{
      uid: to_string(user["id"]),
      provider: __MODULE__ |> to_string |> String.split(".") |> List.last |> String.downcase,
      email: user["email"],
      first_name: List.first(name) || nil,
      last_name: (if length(name) > 1, do: List.last(name), else: nil),
      access_token: token.access_token,
      refresh_token: token.refresh_token,
      nickname: user["login"],
      image: user["avatar_url"],
      phone: nil
    }
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
