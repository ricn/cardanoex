defmodule Cardanoex.Address do
  alias Cardanoex.Backend

  @moduledoc """
  The Address module lets you work with addresses for a wallet.
  """

  @type address :: %{
          id: String.t(),
          state: String.t(),
          derivation_path: list(String.t())
        }

  @type inspected_address :: %{
          address_style: String.t(),
          stake_reference: String.t(),
          network_tag: non_neg_integer() | nil,
          spending_key_hash: String.t(),
          spending_key_bech32: String.t(),
          stake_key_hash: String.t(),
          stake_key_bech32: String.t(),
          script_hash: String.t(),
          script_hash_bech32: String.t(),
          pointer: %{
            slot_num: non_neg_integer(),
            transaction_index: non_neg_integer(),
            output_index: non_neg_integer()
          },
          address_root: String.t(),
          derivation_path: String.t()
        }

  @spec list(String.t()) :: {:error, String.t()} | {:ok, address()}
  @doc """
  Return a list of known addresses, ordered from newest to oldest

  ## Options
    * `wallet_id` - hex based string. 40 characters
  """
  def list(wallet_id) do
    Backend.list_addresses(wallet_id)
  end

  @spec inspect(String.t()) :: {:error, String.t()} | {:ok, inspected_address}
  @doc """
  Give useful information about the structure of a given address.

  ## Options
    * `address`
  """
  def inspect(address) do
    Backend.inspect_address(address)
  end
end
