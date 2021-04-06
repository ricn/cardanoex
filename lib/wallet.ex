defmodule Cardano.Wallet do
  defstruct id: nil,
            name: nil,
            address_pool_gap: nil,
            assets: [],
            balance: %{},
            delegation: %{},
            passphrase: %{},
            tip: %{},
            state: %{}

  alias Cardano.Backend
  alias Cardano.Util

  def create_wallet(options \\ []) do
    default = [
      name: nil,
      mnemonic_sentence: nil,
      passphrase: nil,
      mnemonic_second_factor: nil,
      address_pool_gap: 20
    ]

    opts = Enum.into(Keyword.merge(default, options), %{})

    result =
      Backend.create_wallet(
        opts.name,
        opts.mnemonic_sentence,
        opts.passphrase,
        opts.mnemonic_second_factor,
        opts.address_pool_gap
      )

    case result do
      {:ok, wallet} -> {:ok, Util.keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  def fetch(id) do
    case Backend.fetch_wallet(id) do
      {:ok, wallet} -> {:ok, Util.keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  def list() do
    case Backend.list_wallets() do
      {:ok, wallets} -> {:ok, Enum.map(wallets, fn w -> Util.keys_to_atom(w) end)}
      {:error, message} -> {:error, message}
    end
  end

  def delete(id) do
    case Backend.delete_wallet(id) do
      {:ok, _} -> {:ok, :no_content}
      {:error, message} -> {:error, message}
    end
  end

  def fetch_utxo_stats(id) do
    case Backend.fetch_wallet_utxo_stats(id) do
      {:ok, utxo_stats} -> {:ok, Util.keys_to_atom(utxo_stats)}
      {:error, message} -> {:error, message}
    end
  end

  def update(id, name) do
    case Backend.update_wallet_metadata(id, name) do
      {:ok, wallet} -> {:ok, Util.keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  def update_passphrase(id, old_passphrase, new_passphrase) do
    case Backend.update_wallet_passphrase(id, old_passphrase, new_passphrase) do
      {:ok, _} -> {:ok, :no_content}
      {:error, message} -> {:error, message}
    end
  end
end
