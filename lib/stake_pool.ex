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
end
