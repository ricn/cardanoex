defmodule Cardanoex.Key do
  alias Cardanoex.Backend
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
end
