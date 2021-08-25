defmodule Cardanoex.Address do
  alias Cardanoex.Backend

  @moduledoc """
  The Address module lets you work with addresses for a wallet.
  """

  @doc """
  Return a list of known addresses, ordered from newest to oldest

  ## Options
    * `wallet_id` - hex based string. 40 characters
  """
  def list(wallet_id) do
    Backend.list_addresses(wallet_id)
  end

  @doc"""
  Give useful information about the structure of a given address.

  ## Options
    * `address`
  """
  def inspect(address) do
    Backend.inspect_address(address)
  end
end
