# Clandestine

Your nodes can talk to eachother using `:rpc` with safer payloads!

Like agents in the field, nodes need to communicate in a cryptic fashion.

At first is was called _saferpc_ but that's not true. It's just safe(r) function arguments :joy:

You need to set the enviornment variable `RPC_TOKEN` prior to using this! :pray:

Make sure you generate a strong secret :key:

### Example use

`export RPC_TOKEN=abc123`

Then:

```elixir
secret_list = Clandestine.encrypt("hello world")

Clandestine.decrypt(secret_list)
```

### Use Cases

Built for being used with `:rpc`. Can be used with distributed `Genserver`/`Node.spawn`/`Task.async`/etc...

Say you have a module on a remote node called `foo@example.com`:

```elixir
defmodule Demo do
  def reply(msg) do
    IO.inspect msg
  end

  def reply(:shh, secret) do
    IO.inspect Clandestine.decrypt(secret)
  end
end
```

Now on a node `bar@example.com`:

```elixir
:rpc.call(:foo@example.com, Demo, :reply, ["hello"])

# => "hello"
```

The argument is not encrypted. You will be sending this plain text over the wire.

Now pattern match the `:shh` argument, and send over an encrypted payload:

```elixir
secret = Clandestine.encrypt("hello")

:rpc.call(:foo@example.com, Demo, :reply, [:shh, secret])

# => "hello"
```

Assuming both nodes share the same ENV variable (RPC_TOKEN), the argument will be encrypted prior to being sent and then decrypted in the response.

What you really want to do is encrypted on its way back to ensure safe travel, and then decrypt it back on your end.

***

Say you need the other node to do some work with your payload:

```
defmodule Demo do
  def do_math(secret) do
    num = Clandestine.decrypt(secret)

    result = num + 42

    Clandestine.encrypt(result)
  end
end
```

Now on the other node requesting work:

```elixir
base_num = Clandestine.encrypt(9000)

secret = :rpc.call(:name@hostname, Demo, :do_math, [base_num])

IO.inspect Clandestine.decrypt(secret)

# => 9042
```

Your payloads have been kept secret the whole time. Both times over the wire :pray:

### Disclaimer

Not really that safe! Only as safe as your key, and the larger the payload the safer the messages.

This is not some fancy algorithm. It's pretty much a cipher that is based on both parties sharing the same secret.

I use it because _why not_. I would recommend looking up how to set up TLS with `:rpc` if you need bullet proof data transfer. Or use a VPC for inner node communication.
