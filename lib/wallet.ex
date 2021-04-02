defmodule Cardano.Wallet do
  alias Cardano.Backend

  def create_wallet(options \\ []) do
    default = [
      name: nil,
      mnemonic_sentence: nil,
      passphrase: nil,
      mnemonic_second_factor: nil,
      address_pool_gap: 20
    ]

    opts = Enum.into(Keyword.merge(default, options), %{})

    Backend.create_wallet(
      opts.name,
      opts.mnemonic_sentence,
      opts.passphrase,
      opts.mnemonic_second_factor,
      opts.address_pool_gap
    )
  end

  def fetch(id) do
    Backend.fetch_wallet(id)
  end

  def list() do
    Backend.list_wallets()
  end

  def delete(id) do
    Backend.delete_wallet(id)
  end
end
