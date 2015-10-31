# HR (department for your application.)

[![Build Status](https://travis-ci.org/Zensavona/hr.svg?branch=master)](https://travis-ci.org/Zensavona/hr) [![Inline docs](http://inch-ci.org/github/zensavona/hr.svg?branch=master)](http://inch-ci.org/github/zensavona/hr) [![Coverage Status](https://coveralls.io/repos/Zensavona/hr/badge.svg?branch=master&service=github)](https://coveralls.io/github/Zensavona/hr?branch=master) [![hex.pm version](https://img.shields.io/hexpm/v/hr.svg)](https://hex.pm/packages/hr) [![hex.pm downloads](https://img.shields.io/hexpm/dt/hr.svg)](https://hex.pm/packages/hr) [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

### [Read the docs](https://hexdocs.pm/hr)

A feature rich and highly customisable user account and authorisation library for Phoenix Framework, heavily inspired by Devise for Rails.


<hr>
<h4 style="color:red;">HR is still under active development and while feature complete, does not have full test coverage and is <strong>not recommended for production use at this stage</strong>. It will be ready for the primetime soon, I promise :heart:</h4>
<hr>






## Installation

HR comes with some generators for installing configuration and creating HR preconfigured models (you can have as many models which represent 'users' as you like). This guide assumes you're creating a new model, but there's a [wiki page](todo...) about adding HR to an existing model. For the purpose of this example, our model will be called User, but it can be called whatever you like. The routes and helpers will match what you name the model.

First, add HR to your `mix.exs` deps section with `{:hr, "~> 0.1.3"}` and add `:hr` to the list of `applications`.

Next, run `mix deps.get` to pull down HR and it's dependencies, then `mix hr.gen.model User users` (this builds on `phoenix.gen.model`, and accepts the same options), and `mix ecto.migrate`. Now we have two new models and migrations: User, and UserIdentities. UserIdentities takes care of credentials and information about a User which is not their email and password (an example of this is OAuth tokens).

Let's take a quick look at the User model:

````
defmodule HrExample.User do
  use HrExample.Web, :model
  use Hr.Behaviours, [:registerable, :database_authenticatable, :recoverable, :confirmable]
  # optionally add :oauthable to authenticate users with the oauth providers you specify in config/hr.exs

  schema "users" do

    field :password, :string, virtual: :true
    field :email, :string
    field :unconfirmed_email, :string
    field :password_hash, :string
    field :confirmation_token, :string
    field :confirmed_at, Ecto.DateTime
    field :confirmation_sent_at, Ecto.DateTime
    field :password_reset_token, :string
    field :reset_password_sent_at, Ecto.DateTime
    field :failed_attempts, :integer, default: 0
    field :locked_at, Ecto.DateTime
    has_many :user_identities, Phoenixgram.UserIdentity

    timestamps
  end
````

Looks just like a regular Phoenix model, except for the `use Hr.Behaviours`. You can remove any of these to disable the corresponding feature, and add `:oauthable` to allow this model to be authenticatable with OAuth. You can set the OAuth providers in `config/hr.exs`. Right now only GitHub is supported, but I'm in the process of adding Facebook, Instagram, Twitter and Google.

Ok, next up, we need to run `mix hr.install`, which adds `config/hr.exs`, `web/templates/hr_email` and `web/hr_i18n.ex`.

You should get some instructions in your terminal to add the line `import_config "hr.exs"` to the end of your `config/config.exs`, so go ahead and do that.

Now, the last step: we need to tell our router to use HR's authentication logic and routes, and where to put them.

Change your router so it looks like the one below, we'll go over what each change does and how to customise things in a moment.

````
defmodule HrExample.Router do
  use HrExample.Web, :router
  use Hr.RouterHelper

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :users do
    plug :hr_for, :user
  end

  scope "/" do
    pipe_through [:browser, :users]
    hr_routes_for :user

    get "/", HrExample.PageController, :index
  end
end
````

The first addition, `use Hr.RouterHelper`, provides us with a plug and a macro for configuring HR routes and helpers.

```
pipeline :users do
  plug :hr_for, :user
end
```

Adding a pipeline containing the `hr_for` plug for our model is a neat way to be able to add cookie handling and authentication to the plug pipeline easily. The name `:users` has no particular significance and if you prefer, you can just add `plug :hr_for, :user` to your existing pipeline.

`hr_routes_for :user` creates routes and helpers for the `User` model within the `/` scope. Note that we've also changed `scope "/", HrExample` to `scope "/" do` and changed `get "/", PageController, :index` to `get "/", HrExample.PageController, :index`. This is because by default Phoenix assumes all code running inside this scope will begin with the `HrExample` namespace.


** WIP **
