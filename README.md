# Cardanoex

[![Hex.pm](https://img.shields.io/hexpm/v/cardanoex.svg)](https://hex.pm/packages/cardanoex)
[![Tests](https://github.com/ricn/cardanoex/actions/workflows/elixir.yml/badge.svg)](https://github.com/ricn/cardanoex/actions/workflows/elixir.yml)
[![Inline docs](http://inch-ci.org/github/ricn/cardanoex.svg?branch=master)](http://inch-ci.org/github/ricn/cardanoex)
[![Coverage Status](https://coveralls.io/repos/github/ricn/cardanoex/badge.svg?branch=master)](https://coveralls.io/github/ricn/cardanoex?branch=master)

The library is still in early development. Consider it experimental and the API might change in the future.

This library is the implementation of [the idea](https://cardano.ideascale.com/a/dtd/Elixir-library/350635-48088) submitted to Catalyst project.

## Prerequisites

1. You need to have the [cardano-wallet](https://github.com/input-output-hk/cardano-wallet) up and running

## Installation

Add `cardanoex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cardanoex, "~> 0.2.0"}
  ]
end
```

## Configuration
In `config/config.exs`, add url to the cardano-wallet

```elixir
config :cardanoex,
  wallet_base_url: "http://localhost:8090/v2"
```

## Example usage

### Create a wallet
```elixir
name = "Wallet #1"
mnemonic = Util.generate_mnemonic()
pass = "Super_Secret3.14!"
    
{:ok, wallet} = Wallet.create_wallet(name: name, mnemonic_sentence: mnemonic, passphrase: pass)
```
### List all transactions
```elixir
{:ok, transactions} = Transaction.list(wallet.id)
```
### Send a transaction
```elixir
payments = %{
  passphrase: "Super_Secret3.14!",
  payments: [
          %{
            address:
              "addr_test1qqt6c697uderxaccgn...m64dsuzfj8f",
            amount: %{quantity: 1_000_000, unit: "lovelace"}
           }
  ]
}

{:ok, transaction} = Transaction.create(wallet.id, payments)
```


## Donate

If you like to support the idea with a donation, the address is:
`addr1qyfe0we0tkdu9qn8ztufplz0lmktgpx9zxnj54cd7y359wsyhwvjrl2zkf5cy72yv6p47f2gs5zglyplfggh6e5n4p0sdvvrng`