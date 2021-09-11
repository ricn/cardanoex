defmodule Cardanoex.Wallet do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @type wallet_id :: String.t()
  @type assets :: %{
          available: list(),
          total: list()
        }
  @type balance :: %{
          available: %{quantity: non_neg_integer(), unit: String.t()},
          reward: %{quantity: non_neg_integer(), unit: String.t()},
          total: %{quantity: non_neg_integer(), unit: String.t()}
        }
  @type delegation :: %{active: %{status: String.t()}, next: list()}
  @type passphrase :: %{last_updated_at: String.t()}
  @type state :: %{progress: %{quantity: non_neg_integer(), unit: String.t()}, status: String.t()}
  @type tip :: %{
          absolute_slot_number: non_neg_integer(),
          epoch_number: non_neg_integer(),
          height: %{quantity: non_neg_integer(), unit: String.t()},
          slot_number: non_neg_integer(),
          time: String.t()
        }
  @type wallet :: %{
          address_pool_gap: non_neg_integer(),
          assets: assets(),
          balance: balance(),
          delegation: delegation(),
          id: String.t(),
          name: String.t(),
          passphrase: passphrase(),
          state: state(),
          tip: tip()
        }

  @type utxo_stats :: %{
          distribution: %{
            "10": non_neg_integer(),
            "100": non_neg_integer(),
            "1000": non_neg_integer(),
            "10000": non_neg_integer(),
            "100000": non_neg_integer(),
            "1000000": non_neg_integer(),
            "10000000": non_neg_integer(),
            "100000000": non_neg_integer(),
            "1000000000": non_neg_integer(),
            "10000000000": non_neg_integer(),
            "100000000000": non_neg_integer(),
            "1000000000000": non_neg_integer(),
            "10000000000000": non_neg_integer(),
            "100000000000000": non_neg_integer(),
            "1000000000000000": non_neg_integer(),
            "10000000000000000": non_neg_integer(),
            "45000000000000000": non_neg_integer()
          },
          scale: String.t(),
          total: %{quantity: non_neg_integer(), unit: String.t()}
        }

  @moduledoc """
  The wallet module lets you work with Cardano wallets.

  Wallets are identified by unique ID which is deterministically derived from the seed (mnemonic phrase),
  so each time you delete and create a wallet again, it receives the same ID.
  """

  @spec create_wallet(
          name: String.t(),
          mnemonic_sentence: String.t(),
          passphrase: String.t(),
          mnemonic_second_factor: String.t()
        ) ::
          {:error, String.t()} | {:ok, wallet()}
  @doc """
  Create and restore a wallet from a mnemonic sentence.

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

  @spec fetch(wallet_id()) :: {:error, String.t()} | {:ok, wallet()}
  @doc """
  Fetch a wallet by wallet id

  ## Options
    * `wallet_id` - hex based string. 40 characters
  """
  def fetch(wallet_id) do
    case Backend.fetch_wallet(wallet_id) do
      {:ok, wallet} -> {:ok, Util.keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  @spec list :: {:error, String.t()} | {:ok, list(wallet())}
  @doc """
  Return a list of known wallets, ordered from oldest to newest.
  """
  def list() do
    case Backend.list_wallets() do
      {:ok, wallets} -> {:ok, Enum.map(wallets, fn w -> Util.keys_to_atom(w) end)}
      {:error, message} -> {:error, message}
    end
  end

  @spec delete(wallet_id()) :: {:error, String.t()} | :ok
  @doc """
  Delete wallet by wallet id

  ## Options
    * `wallet_id` - hex based string. 40 characters
  """
  def delete(wallet_id) do
    case Backend.delete_wallet(wallet_id) do
      {:ok, _} -> :ok
      {:error, message} -> {:error, message}
    end
  end

  @spec fetch_utxo_stats(wallet_id()) :: {:error, String.t()} | {:ok, utxo_stats()}
  @doc """
  Return the UTxOs distribution across the whole wallet, in the form of a histogram.

  ## Options
    * `wallet_id` - hex based string. 40 characters
  """
  def fetch_utxo_stats(wallet_id) do
    case Backend.fetch_wallet_utxo_stats(wallet_id) do
      {:ok, utxo_stats} -> {:ok, Util.keys_to_atom(utxo_stats)}
      {:error, message} -> {:error, message}
    end
  end

  @spec update(wallet_id(), String.t()) :: {:error, String.t()} | {:ok, wallet()}
  @doc """
  Update the name of a wallet

  ## Options
    * `wallet_id` - hex based string. 40 characters
    * `new_name` - the new name for the wallet
  """
  def update(wallet_id, new_name) do
    case Backend.update_wallet_metadata(wallet_id, new_name) do
      {:ok, wallet} -> {:ok, Util.keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  @spec update_passphrase(wallet_id(), String.t(), String.t()) ::
          {:error, String.t()} | :ok
  @doc """
  Update passphrase for a wallet

  ## Options
    * `wallet_id` - hex based string. 40 characters
    * `old_passphrase` - the old passphrase
    * `new_passphrase` - the new passphrase
  """
  def update_passphrase(wallet_id, old_passphrase, new_passphrase) do
    case Backend.update_wallet_passphrase(wallet_id, old_passphrase, new_passphrase) do
      {:ok, _} -> :ok
      {:error, message} -> {:error, message}
    end
  end
end
