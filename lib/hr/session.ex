defmodule Hr.Session do
  import Plug.Conn

  def login(conn, entity, user) do
    conn
    |> assign(:"current_#{entity}", user)
    |> put_session(:"hr_#{entity}_id", user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

end
# TODO: macros to name the conn vars beautifly
