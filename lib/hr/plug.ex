defmodule Hr.Plug do
  import Plug.Conn
  import Hr.RouterHelper

  def hr_for(conn, entity) do
    put_private(conn, :hr_entity, entity)
  end
end
