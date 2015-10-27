defmodule Hr.BaseJWTController do
  @moduledoc """
  Base form controller. Can be "inherited" from by using `use Hr.BaseJWTController`.
  A good example of this is in `Hr.JWTController`
   """
  defmacro __using__(_) do
    quote do
      use Phoenix.Controller


      @doc """
      def update(conn, %{"id" => id, "post" => post_params}) do
        post = Repo.get!(Post, id)
        changeset = Post.changeset(post, post_params)

        case Repo.update(changeset) do
          {:ok, post} ->
            render(conn, "show.json", post: post)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(PeepBlogBackend.ChangesetView, "error.json", changeset: changeset)
        end
      end
      """

      @doc """
      Check if the submitted credentials are valid, if they are, create a session
      """
      def create_session(conn, %{"email" => email, "password" => password}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        case Hr.UserHelper.authenticate_with_email_and_password(model, repo, email, password) do
          {:ok, user} ->
            token = Hr.JWT.create(entity, user)
            conn |> render("authenticate.json", token: token)
          {:error, _reason} ->
            conn
            |> put_status(:unauthorized)
            |> render("error.json", errors: ["Invalid credentials"])
        end
      end

      @doc """
      Create a new user if the email address isn't already taken.
      """
      def create_signup(conn, data) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(Module.concat(app, Router.Helpers), :"#{entity}_signup_path", [Module.concat(app, Endpoint), :create_signup])

        params = data[entity]
        confirmable? = Enum.member? model.hr_behaviours, :confirmable

        if confirmable? do
          {changeset, token} = Hr.Model.confirmable_signup_changeset(model.__struct__, params)
        else
          changeset = Hr.Model.signup_changeset(model.__struct__, params)
        end

        case repo.insert(changeset) do
          {:ok, user} ->
            if confirmable? do
              link = Hr.Meta.confirmation_url(conn, user.id, token)
              Hr.Meta.mailer(app).send_confirmation_email(user, link)
              conn
              |> put_flash(:info, Hr.Meta.i18n(app, "registrations.signed_up_but_unconfirmed", email: user.unconfirmed_email))
              |> redirect(to: Hr.Meta.signed_up_url)
            else
              conn
              |> Hr.Session.login(entity, user)
              |> put_flash(:info, Hr.Meta.i18n(app, "sessions.signed_in"))
              |> redirect(to: Hr.Meta.logged_in_url)
            end
          {:error, changeset} ->
            conn
            |> put_layout({Module.concat(app, LayoutView), :app})
            |> put_view(Hr.Meta.form_view(app))
            |> render("signup.html", changeset: changeset, path: path)
        end
      end

      @doc """
      Confirms the email for the user
      """
      def confirmation(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn

        user = repo.get! model, user_id
        changeset = Hr.Model.confirmation_changeset(user, params)

        if changeset && changeset.valid? do
          repo.update!(changeset)
          conn
          |> put_flash(:info, Hr.Meta.i18n(app, "confirmations.confirmed"))
          |> redirect(to: Hr.Meta.signed_up_url)
        else
          conn
          |> put_flash(:error, Hr.Meta.i18n(app, "confirmations.invalid_confirmation_token"))
          |> redirect(to: Hr.Meta.signed_up_url)
        end
      end

      @doc """
      If the email exists, send a reset link
      """
      def create_password_reset_request(conn, %{"reset" => %{"email" => email}}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        user = repo.get_by! model, email: email

        case user do
          nil ->
            nil
          user ->
            {changeset, token} = Hr.Model.reset_changeset(user)
            repo.update!(changeset)
            link = Hr.Meta.reset_url(conn, user.id, token)
            Hr.Meta.mailer(app).send_reset_email(user, link)
        end
        conn
        |> put_flash(:info, Hr.Meta.i18n(app, "passwords.send_instructions"))
        |> redirect(to: Hr.Meta.signed_up_url)
      end

      @doc """
      Reset the user's password
      """
      def create_password_reset(conn, %{"reset" => params}) do
        {entity, model, repo, app} = Hr.Meta.stuff conn
        path = apply(Module.concat(app, Router.Helpers), :"#{entity}_password_reset_path", [Module.concat(app, Endpoint), :create_password_reset])

        case Hr.UserHelper.get_with_id_and_token(repo, model, params["id"], params["password_reset_token"]) do
          {:ok, user} ->
            changeset = Hr.Model.new_password_changeset(user, params)
            if changeset.valid? do
              repo.update!(changeset)
              conn
              |> put_flash(:info, Hr.Meta.i18n(app, "passwords.updated"))
              |> redirect(to: Hr.Meta.signed_up_url)
            else
              conn
              |> put_layout({Module.concat(app, LayoutView), :app})
              |> put_flash(:error, Hr.Meta.i18n(app, "passwords.invalid"))
              |> put_view(Hr.Meta.form_view(app))
              |> render("password_reset.html", changeset: changeset, id: params["id"], token: params["password_reset_token"], path: path)
            end
          {:error, _} ->
            conn
            |> put_flash(:error, Hr.Meta.i18n(app, "passwords.no_token"))
            |> redirect(to: Hr.Meta.signed_up_url)
        end
      end
    end
  end
end

defmodule Hr.JWTController do
  @moduledoc """
  The default implementation of JWTController. If you want to override
  it, either direct your routes to your own implementation (if you want to
  just override a couple of actions), or implement `YourApp.HrJWTController`
  with `use Hr.BaseJWTController`.
  """
  use Hr.BaseJWTController
end
