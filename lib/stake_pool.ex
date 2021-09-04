defmodule Cardanoex.StakePool do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @moduledoc """
  The stake pool module let's you manage stake pools.
  """

  @doc """
  List all known stake pools ordered by descending non_myopic_member_rewards. The non_myopic_member_rewards — and thus the ordering — depends on the `stake` parameter.

  Some pools may also have metadata attached to them.

  ### Options
    * stake - The stake the user intends to delegate in Lovelace. Required.
  """
  def list(stake) do
    case Backend.list_stake_pools(stake) do
      {:ok, stake_pools} -> {:ok, Enum.map(stake_pools, fn s -> Util.keys_to_atom(s) end)}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  List stake-keys relevant to the wallet, and how much ada is associated with each.

  ### Options
    * `wallet_id` - hex based string. 40 characters
  """
  def list_stake_keys(wallet_id) do
    case Backend.list_stake_keys(wallet_id) do
      {:ok, stake_keys} -> {:ok, Util.keys_to_atom(stake_keys)}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Returns the current status of the stake pools maintenance actions.
  """
  def view_maintenance_actions do
    case Backend.view_maintenance_actions() do
      {:ok, actions} -> {:ok, Util.keys_to_atom(actions)}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Estimate fee for joining or leaving a stake pool. Note that it is an estimation because a delegation induces a transaction for which coins have to be selected randomly within the wallet. Because of this randomness, fees can only be estimated.

  ### Options
    * `wallet_id` - hex based string. 40 characters
  """
  def estimate_fee(wallet_id) do
    case Backend.delegation_fees(wallet_id) do
      {:ok, estimated_fees} -> {:ok, Util.keys_to_atom(estimated_fees)}
      {:error, message} -> {:error, message}
    end
  end
end
