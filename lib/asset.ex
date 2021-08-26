defmodule Cardanoex.Asset do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  def list(wallet_id) do
    case Backend.list_assets(wallet_id) do
      {:ok, assets} -> {:ok, Enum.map(assets, fn a -> Util.keys_to_atom(a) end)}
      {:error, message} -> {:error, message}
    end
  end

  def get(wallet_id, policy_id) do
    case Backend.get_asset(wallet_id, policy_id) do
      {:ok, asset} -> {:ok, Util.keys_to_atom(asset)}
      {:error, message} -> {:error, message}
    end
  end

  def mint_burn(wallet_id, mint_burn_info) do
    case Backend.mint_burn_asset(wallet_id, mint_burn_info) do
      {:ok, transaction} -> {:ok, Util.keys_to_atom(transaction)}
      {:error, message} -> {:error, message}
    end
  end
end
