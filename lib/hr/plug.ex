defmodule Hr.Plug do
  import Plug.Conn
  import Joken

  def hr_for(conn, entity) do
    conn = put_private(conn, :hr_entity, entity)
    {entity, model, repo, app} = Hr.Meta.stuff(conn)


    user_id = get_session(conn, :"hr_#{entity}_id")
    user = user_id && repo.get(model, user_id)
    assign(conn, :"current_#{entity}", user)
  end

  def hr_jwt_for(conn, entity) do
    conn = put_private(conn, :hr_entity, entity)
    {entity, model, repo, app} = Hr.Meta.stuff(conn)

    case get_req_header(conn, "authorization") do
      [auth] ->
        # |> with_validation("user_id", &(&1 == 21)) ?
        auth = auth |> token |> with_signer(hs256("my_secret")) |> verify

        user = case auth do
          %{error: nil} ->
            IO.inspect "OK, cool ============"
            repo.get_by(model, [id: auth.claims["id"], email: auth.claims["email"]])
          _ ->
            IO.inspect "INCORRECT"
            ""
        end
        IO.inspect user

        assign(conn, :"current_#{entity}", user)
      _ ->
        conn
    end
  end
end
