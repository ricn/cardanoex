# Cardanoex

The library is still in early development. Consider it experimental and the API might change in the future.

This library is the implementation of [the idea](https://cardano.ideascale.com/a/dtd/Elixir-library/350635-48088) submitted to Catalyst project.

## Prerequisites

1. You need to have the [cardano-wallet](https://github.com/input-output-hk/cardano-wallet) up and running

## Installation

Add `cardanoex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cardanoex, "~> 0.1.0"}
  ]
end
```

## Configuration
In `config/config.exs`, add url to the cardano-wallet

```elixir
config :cardanoex,
  wallet_base_url: "http://localhost:8090/v2"
```