defmodule Cardanoex.Asset do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @moduledoc """
  The asset module let's you work with native assets for a wallet.
  """

  @doc """
  List all native assets for a wallet.

  ## Options
    * `wallet_id` - hex based string. 40 characters
  """
  def list(wallet_id) do
    case Backend.list_assets(wallet_id) do
      {:ok, assets} -> {:ok, Enum.map(assets, fn a -> Util.keys_to_atom(a) end)}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Get information about a specific asset.

  ## Options
    * `wallet_id` - hex based string. 40 characters
    * `policy_id` - hex based string. 56 characters
  """
  def get(wallet_id, policy_id) do
    case Backend.get_asset(wallet_id, policy_id) do
      {:ok, asset} -> {:ok, Util.keys_to_atom(asset)}
      {:error, message} -> {:error, message}
    end
  end
end
