defmodule Hr.Session do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2]

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_private(:hr_user_id, user.id)
    |> put_session(:hr_user_id, user.id)
    |> configure_session(renew: true)
  end

  def authenticate_with_email_and_password(conn, changeset) do
    user = Hr.Repo.get_user(email: changeset.params["email"])
    cond do
      user && checkpw(changeset.params["password"], user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized, conn}
      true ->
        {:error, :not_found, conn}
    end
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
