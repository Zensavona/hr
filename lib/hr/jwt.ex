defmodule Hr.JWT do
  @moduledoc """
  Functionality for encoding and decoding JWT tokens with Joken
  """
  import Joken

  def create(entity, user) do
    %{email: user.email, id: user.id, entity: to_string(entity)}
    |> token
    |> with_signer(hs256("my_secret"))
    |> sign
    |> get_compact
  end
end
