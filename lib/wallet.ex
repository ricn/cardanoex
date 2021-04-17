defmodule Cardanoex.Wallet do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @moduledoc """
  The wallet module lets you work with Cardano wallets.

  Wallets are identified by unique ID which is deterministically derived from the seed (mnemonic phrase),
  so each time you delete and create a wallet again, it receives the same ID.
  """

  @doc """
  Create and restore a wallet from a mnemonic sentence.

  Returns a map that looks like this:
  ``

  ## Options
    * `name` - A human readable name for the wallet
    * `mnemonic_sentence` - A list of bip-0039 mnemonic words. 15-24 words.
    * `passphrase` - A master passphrase to lock and protect the wallet for sensitive operation (e.g. sending funds)
    * `mnemonic_second_factor` - An optional passphrase used to encrypt the mnemonic sentence. A list of bip-0039 mnemonic words. 9-12 words.
    * `address_pool_gap` - Number of consecutive unused addresses allowed. Default is 20.

      IMPORTANT DISCLAIMER: Using values other than 20 automatically makes your wallet invalid with regards to BIP-44 address discovery.
      It means that you will not be able to fully restore your wallet in a different software which is strictly following BIP-44.

      Beside, using large gaps is not recommended as it may induce important performance degradations. Use at your own risks.
  """
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
