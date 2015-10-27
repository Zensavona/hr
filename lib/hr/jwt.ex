defmodule Hr.JWT do
  @moduledoc """
  Functionality for encoding and decoding JWT tokens with Joken
  """
  import Joken

  def create(conn, entity, user) do
    %{email: user.email, id: user.id, entity: to_string(entity)}
    |> token
    |> with_signer(hs256(conn.secret_key_base))
    |> sign
    |> get_compact
  end

  def refresh(conn, stale_token) do
    decoded = stale_token |> token |> with_signer(hs256(conn.secret_key_base)) |> verify

    case decoded do
      %{error: nil} ->
        fresh = %{email: decoded.claims["email"], id: decoded.claims["id"], entity: decoded.claims["entity"]}
        |> token
        |> with_signer(hs256(conn.secret_key_base))
        |> sign
        |> get_compact

        {:ok, fresh}
      _ ->
        {:error, decoded.error}
    end
  end
end
