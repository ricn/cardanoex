defmodule Cardanoex.StakePool do
  alias Cardanoex.Backend
  alias Cardanoex.Util
  alias Cardanoex.Transaction

  @moduledoc """
  The stake pool module let's you manage stake pools.
  """

  @type stake_pool :: %{
          id: String.t(),
          metrics: %{
            non_myopic_member_rewards: %{
              quantity: non_neg_integer(),
              unit: String.t()
            }
          },
          relative_stake: %{
            quantity: float(),
            unit: String.t()
          },
          saturation: float(),
          produced_blocks: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          cost: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          margin: %{
            quantity: float(),
            unit: String.t()
          },
          pledge: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          metadata: %{
            ticker: String.t(),
            name: String.t(),
            description: String.t(),
            homepage: String.t()
          },
          retirement: %{
            epoch_number: non_neg_integer(),
            epoch_start_time: String.t()
          },
          flags: list(String.t())
        }

  @type stake_key :: %{
          ours:
            list(%{
              index: non_neg_integer(),
              key: String.t(),
              stake: %{quantity: non_neg_integer(), unit: String.t()},
              reward_balance: %{quantity: non_neg_integer(), unit: String.t()},
              delegation: %{
                active: %{
                  status: String.t(),
                  target: String.t()
                },
                next:
                  list(%{
                    status: String.t(),
                    target: String.t(),
                    changes_at: %{
                      epoch_number: non_neg_integer(),
                      epoch_start_time: String.t()
                    }
                  })
              }
            }),
          foreign:
            list(%{
              key: String.t(),
              stake: %{
                quantity: non_neg_integer(),
                unit: String.t()
              },
              reward_balance: %{
                quantity: non_neg_integer(),
                unit: String.t()
              }
            }),
          none: %{
            stake: %{
              quantity: non_neg_integer(),
              unit: String.t()
            }
          }
        }

  @type fee_estimation :: %{
          estimated_min: %{quantity: non_neg_integer(), unit: String.t()},
          estimated_max: %{quantity: non_neg_integer(), unit: String.t()},
          minimum_coins:
            list(%{
              quantity: non_neg_integer(),
              unit: String.t()
            }),
          deposit: %{quantity: non_neg_integer(), unit: String.t()}
        }

  @spec list(non_neg_integer()) :: {:error, String.t()} | {:ok, list(stake_pool)}
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

  @spec list_stake_keys(String.t()) :: {:error, String.t()} | {:ok, list(stake_key())}
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

  @spec view_maintenance_actions ::
          {:error, String.t()}
          | {:ok,
             %{
               gc_stake_pools: %{
                 status: String.t(),
                 last_run: String.t()
               }
             }}
  @doc """
  Returns the current status of the stake pools maintenance actions.
  """
  def view_maintenance_actions do
    case Backend.view_maintenance_actions() do
      {:ok, actions} -> {:ok, Util.keys_to_atom(actions)}
      {:error, message} -> {:error, message}
    end
  end

  @spec trigger_maintenance_action(String.t()) :: :ok | {:error, String.t()}
  @doc """
  Performs maintenance actions on stake pools, such as triggering metadata garbage collection.

  Actions may not be instantaneous.
  """
  def trigger_maintenance_action(action) do
    case Backend.trigger_maintenance_action(action) do
      {:ok, _result} -> :ok
      {:error, message} -> {:error, message}
    end
  end

  @spec estimate_fee(String.t()) :: {:error, String.t()} | {:ok, fee_estimation}
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

  @spec join(String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, Transaction.transaction()}
  @doc """
  Delegate all (current and future) addresses from the given wallet to the given stake pool.

  *Note:* Bech32-encoded stake pool identifiers can vary in length.

  ### Options
    * `wallet_id` - hex based string. 40 characters
    * `stake_pool_id` - hex|bech32 string
    * `passphrase` - Wallet passphrase
  """
  def join(wallet_id, stake_pool_id, passphrase) do
    case Backend.join_stake_pool(wallet_id, stake_pool_id, passphrase) do
      {:ok, result} -> {:ok, Util.keys_to_atom(result)}
      {:error, message} -> {:error, message}
    end
  end

  @spec quit(String.t(), String.t()) :: {:error, String.t()} | {:ok, Transaction.transaction()}
  @doc """
  Stop delegating completely. The wallet's stake will become inactive.

  ### Options
    * `wallet_id` - hex based string. 40 characters
    * `passphrase` - Wallet passphrase
  """
  def quit(wallet_id, passphrase) do
    case Backend.quit_staking(wallet_id, passphrase) do
      {:ok, result} -> {:ok, Util.keys_to_atom(result)}
      {:error, message} -> {:error, message}
    end
  end
end
