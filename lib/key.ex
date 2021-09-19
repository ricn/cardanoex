defmodule Cardanoex.Key do
  alias Cardanoex.Backend

  @moduledoc """
  The Key module helps you to work with public keys for a wallet.
  """

  @spec get_account_public_key(String.t()) :: {:error, String.t()} | {:ok, String.t()}
  @doc """
  Retrieve the account public key of this wallet.

  ### Options
    * `wallet_id` - hex based string. 40 characters
  """
  def get_account_public_key(wallet_id) do
    case Backend.get_account_public_key(wallet_id) do
      {:ok, account_public_key} -> {:ok, account_public_key}
      {:error, message} -> {:error, message}
    end
  end

  @spec get_public_key(String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, String.t()}
  @doc """
  Return a public key for a given role and derivation index.

  ### Options
    * `wallet_id` - hex based string. 40 characters
    * `role` - utxo_external, utxo_internal or mutable_account"
    * `index` - Example: 1852H. An individual segment within a derivation path. The H suffix indicates a Hardened child private key, which means that children of this key cannot be derived from the public key. Indices without a H suffix are called Soft.
  """
  def get_public_key(wallet_id, role, index) do
    case Backend.get_public_key(wallet_id, role, index) do
      {:ok, public_key} -> {:ok, public_key}
      {:error, message} -> {:error, message}
    end
  end

  @spec create_account_public_key(String.t(), map()) ::
          {:error, String.t()} | {:ok, String.t()}
  @doc """
  Derive an account public key for any account index. For this key derivation to be possible, the wallet must have been created from mnemonic.
  It is possible to use the optional `purpose` field to override that branch of the derivation path with different hardened derivation index.
  If that field is omitted, the default purpose for Cardano wallets (`1852H`) will be used.

  *Note:* Only Hardened indexes are supported by this endpoint.

  ### Options
    * `wallet_id` - hex based string. 40 characters
    * `index` - Example: 1852H. An individual segment within a derivation path. The `H` suffix indicates a Hardened child private key, which means that children of this key cannot be derived from the public key. Indices without a `H` suffix are called Soft.
    * `format` - Enum: "extended" "non_extended". Determines whether extended (with chain code) or normal (without chain code) key is requested.
    * `purpose` - An individual segment within a derivation path. The `H` suffix indicates a Hardened child private key, which means that children of this key cannot be derived from the public key. Indices without a H suffix are called Soft.
  """
  def create_account_public_key(wallet_id, options) do
    passphrase = options[:passphrase]
    index = options[:index]
    format = options[:format]
    purpose = options[:purpose]

    case Backend.create_account_public_key(wallet_id, passphrase, index, format, purpose) do
      {:ok, public_key} -> {:ok, public_key}
      {:error, message} -> {:error, message}
    end
  end
end
