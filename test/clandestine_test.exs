defmodule ClandestineTest do
  use ExUnit.Case
  doctest Clandestine

  def setup do
    yuge_key =
      :crypto.hash(:sha256, to_string(:rand.uniform()))
      |> Base.encode16()
      |> String.slice(0..10)
      |> String.downcase()

    System.put_env("RPC_TOKEN", yuge_key)
  end

  test "it encrypts the term" do
    term = %{hello: 'world'}

    secret_list = Clandestine.encrypt(term)

    assert is_list(secret_list)
    assert Enum.at(secret_list, 0) |> is_number
    assert secret_list != term
  end

  test "it decrypts the term" do
    term = %{hello: 'world'}

    secret_list = Clandestine.encrypt(term)

    assert Clandestine.decrypt(secret_list) == term
  end
end
