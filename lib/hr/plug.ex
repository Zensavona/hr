defmodule Hr.Plug do
  import Plug.Conn
  import Joken
  import Phoenix.Controller

  def hr_for(conn, entity) do
    conn = conn
    |> put_private(:hr_entity, entity)
    |> put_private(:hr_auth_type, "form")

    {entity, model, repo, _} = Hr.Meta.stuff(conn)


    user_id = get_session(conn, :"hr_#{entity}_id")
    user = user_id && repo.get(model, user_id)
    assign(conn, :"current_#{entity}", user)
  end

  def hr_jwt_for(conn, entity) do
    conn = conn
    |> put_private(:hr_entity, entity)
    |> put_private(:hr_auth_type, "jwt")

    IO.inspect "INCOMING JWT CONN:"
    IO.inspect conn

    {entity, model, repo, _} = Hr.Meta.stuff(conn)

    case get_req_header(conn, "authorization") do
      [auth] ->
        IO.inspect "AUTHORIZATION HEADER FOUND: "
        IO.inspect auth

        auth = auth
        |> String.split(" ")
        |> List.last
        |> token
        |> with_signer(hs256(conn.secret_key_base))
        |> verify

        IO.inspect "TOKEN VERIFIED (?): "
        IO.inspect auth


        user = case auth do
          %{error: nil} ->
            user = repo.get_by(model, [id: auth.claims["id"], email: auth.claims["email"]])
            IO.inspect "NO ERRORS, USER:"
            IO.inspect user

            user
          _ ->
            IO.inspect "ERRORS..."
            IO.inspect auth

            false
        end
        assign(conn, :"current_#{entity}", user)
      _ ->
        IO.inspect "NO AUTHORIZATION HEADER FOUND..."
        conn
    end
  end

  def authenticate_user(conn, _opts) do
    IO.inspect conn
    
    {_, _, _, app} = Hr.Meta.stuff conn
    if Map.has_key?(conn.assigns, :current_user) && conn.assigns.current_user do
      conn
    else
      case conn.private.hr_auth_type do
        "jwt" ->
          conn
          |> put_view(Hr.JWTView)
          |> put_status(:unauthorized)
          |> render("error.json", errors: [Hr.Meta.i18n(app, "errors.unauthenticated")])
        _ ->
          conn
            |> put_flash(:error, Hr.Meta.i18n(app, "errors.unauthenticated"))
            |> redirect(to: Application.get_env(:hr, :not_logged_in_url))
            |> halt
      end
    end
  end
end
