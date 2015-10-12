defmodule Hr.Plug do
  import Plug.Conn

  def hr_for(conn, entity) do
    conn = put_private(conn, :hr_entity, entity)
    {entity, model, repo, app} = Hr.Meta.stuff(conn)


    user_id = get_session(conn, :"hr_#{entity}_id")
    user = user_id && repo.get(model, user_id)
    assign(conn, :"current_#{entity}", user)
  end
end
