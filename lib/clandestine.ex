defmodule Clandestine do
  def encrypt(term) do
    term
    |> :erlang.term_to_binary()
    |> :binary.bin_to_list()
    |> Enum.with_index()
    |> Enum.map(fn {e, i} -> (e + 1) * secret_char(i) end)
  end

  def decrypt(list) do
    list
    |> Enum.with_index()
    |> Enum.map(fn {e, i} -> ((e - 1) / secret_char(i)) |> trunc end)
    |> :binary.list_to_bin()
    |> :erlang.binary_to_term()
  end

  defp secret_char(i) do
    secret = System.get_env("RPC_TOKEN") |> to_charlist

    secret_length =
      System.get_env("RPC_TOKEN")
      |> to_charlist
      |> length

    Enum.at(secret, rem(i, secret_length))
  end
end
