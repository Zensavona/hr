defmodule HrTest do
  use ExUnit.Case

  setup_all do
    # IO.inspect "setup something idk lol"

    :ok
  end

  test "OAuth strategies are returned correctly" do
    github = Hr.OAuth.Strategies.find("github")
    assert github == Hr.OAuth.GitHub
  end

  test "Confirmable signup changeset validates fields" do
    # {changeset, token} = Hr.Model.confirmable_signup_changeset(%{}, %{email: "test@test.com", password: "password"})
    # not sure what the best approach to 'stubbing out' components of the phoenix app that
    # HR is going to reside within for testing purposes...
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
