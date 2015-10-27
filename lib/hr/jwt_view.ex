defmodule Hr.BaseJWTView do
  defmacro __using__(dir) do
    quote do
      use Phoenix.View, root: unquote(dir)
    end
  end
end

defmodule Hr.JWTView do
  use Hr.BaseFormView, "priv/templates/html"

  @doc """

  def render("index.json", %{posts: posts}) do
    %{posts: render_many(posts, PeepBlogBackend.PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{post: render_one(post, PeepBlogBackend.PostView, "post.json")}
  end



  defmodule PeepBlogBackend.ChangesetView do
    use PeepBlogBackend.Web, :view

    def render("error.json", %{changeset: changeset}) do
      # When encoded, the changeset returns its errors
      # as a JSON object. So we just pass it forward.
      %{errors: changeset}
    end
  end

  """


  def render("authenticate.json", %{token: token}) do
    %{token: token}
  end

  def render("generic_flash.json", %{flash: message}) do
    %{flash: message}
  end

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
