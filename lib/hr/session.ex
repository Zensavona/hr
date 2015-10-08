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

defmodule Hr.UseSessions do
  import Plug.Conn
  @repo Hr.Meta.repo
  @model String.to_atom(Hr.Meta.model_module)


  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    user_id = get_session(conn, :hr_user_id)
    user = user_id && @repo.get(@model, user_id)
    assign(conn, :current_user, user)
    # put_private(:hr_user_id, user.id)
  end
end

# TODO: macros to name the conn vars beautifly
