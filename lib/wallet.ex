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

  def fetch_utxo_stats(id) do
    Backend.fetch_wallet_utxo_stats(id)
  end

  def update(id, name) do
    Backend.update_wallet_metadata(id, name)
  end

  def update_passphrase(id, old_passphrase, new_passphrase) do
    Backend.update_wallet_passphrase(id, old_passphrase, new_passphrase)
  end
end
