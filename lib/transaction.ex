defmodule Cardanoex.Transaction do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @type asset :: %{
          policy_id: String.t(),
          asset_name: String.t(),
          quantity: non_neg_integer()
        }

  @type payment :: %{
          address: String.t(),
          amount: non_neg_integer(),
          assets: list(asset()) | nil
        }

  @type create_transaction :: %{
          passphrase: String.t(),
          payments: list(payment()),
          withdrawal: String.t() | nil,
          metadata: map()
        }

  @type amount :: %{
          quantity: non_neg_integer(),
          unit: String.t()
        }

  @type fee_estimation :: %{
          deposit: amount(),
          estimated_max: amount(),
          estimated_min: amount(),
          minimum_coins: list(amount())
        }

  @type input :: %{
          address: String.t(),
          amount: amount(),
          assets: list(asset()),
          id: String.t(),
          index: non_neg_integer()
        }

  @type output :: %{
          address: String.t(),
          amount: amount(),
          assets: list(asset())
        }

  @type collateral :: %{
          address: String.t(),
          amount: amount(),
          id: String.t(),
          index: non_neg_integer()
        }

  @type withdrawal :: %{
          stake_address: String.t(),
          amount: amount()
        }

  @type transaction ::
          %{
            amount: amount(),
            collateral: list(collateral()),
            deposit: amount(),
            depth: %{quantity: non_neg_integer(), unit: String.t()},
            direction: String.t(),
            expires_at: %{
              absolute_slot_number: non_neg_integer(),
              epoch_number: non_neg_integer(),
              slot_number: non_neg_integer(),
              time: String.t()
            },
            fee: amount(),
            id: String.t(),
            inputs: list(input()),
            inserted_at: %{
              absolute_slot_number: non_neg_integer(),
              epoch_number: non_neg_integer(),
              height: %{quantity: non_neg_integer(), unit: String.t()},
              slot_number: non_neg_integer(),
              time: String.t()
            },
            metadata: map | nil,
            mint: list(),
            outputs: list(output()),
            pending_since: %{
              absolute_slot_number: non_neg_integer(),
              epoch_number: non_neg_integer(),
              height: %{quantity: non_neg_integer(), unit: String.t()},
              slot_number: non_neg_integer(),
              time: String.t()
            },
            status: String.t(),
            withdrawals: list(withdrawal),
            script_validity: String.t() | nil
          }

  @moduledoc """
  The Transaction module lets you work with transactions for a wallet.
  """

  @spec estimate_fee(String.t(), create_transaction()) ::
          {:error, String.t()} | {:ok, fee_estimation()}
  @doc """
  Estimate fee for the transaction.
  The estimate is made by assembling multiple transactions and analyzing the distribution of their fees.
  The `estimated_max` is the highest fee observed, and the `estimated_min` is the fee which is lower than at least 90% of the fees observed.

  ## Options
    * `wallet_id` - hex based string. 40 characters
    * `transaction` - A map with the following structure:

    ```elixir
    %{
      payments: [
            %{
              address: "addr_test1qruzy7l5...nq04es9elzy7",
              amount: %{quantity: 42_000_000, unit: "lovelace"}
            }
          ]
    }

    # With asset:
    %{
      payments: [
        %{
          address:"addr_test1qruzy7l5...nq04es9elzy7",
              amount: %{quantity: 1_407_406, unit: "lovelace"},
              assets: [
                %{
                  policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7",
                  asset_name: "",
                  quantity: 0
                }
              ]
            }
          ]
    }

    # With metadata:
    %{
      payments: [
        %{
          address: "addr_test1qruzy7l5...nq04es9elzy7",
              amount: %{quantity: 1_407_406, unit: "lovelace"}
        }
      ],
      metadata: %{"0" => %{"string" => "cardano"}, "1" => %{"int" => 14}}
    }
    ```
  """
  def estimate_fee(wallet_id, transaction) do
    case Backend.estimate_transaction_fee(wallet_id, transaction) do
      {:ok, fee_estimation} -> {:ok, Util.keys_to_atom(fee_estimation)}
      {:error, message} -> {:error, message}
    end
  end

  @spec create(String.t(), create_transaction()) :: {:error, String.t()} | {:ok, transaction}
  @doc """
  Create and send transaction from the wallet.

  ## Options
    * `wallet_id` - hex based string. 40 characters
    * `transaction` - A map with the following structure:

    ```elixir
    %{
      payments: [
            %{
              address: "addr_test1qruzy7l5...nq04es9elzy7",
              amount: %{quantity: 42_000_000, unit: "lovelace"}
            }
          ]
    }

    # With asset:
    %{
      payments: [
        %{
          address:"addr_test1qruzy7l5...nq04es9elzy7",
              amount: %{quantity: 1_407_406, unit: "lovelace"},
              assets: [
                %{
                  policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7",
                  asset_name: "",
                  quantity: 0
                }
              ]
            }
          ]
    }

    # With metadata:
    %{
      payments: [
        %{
          address: "addr_test1qruzy7l5...nq04es9elzy7",
              amount: %{quantity: 1_407_406, unit: "lovelace"}
        }
      ],
      metadata: %{"0" => %{"string" => "cardano"}, "1" => %{"int" => 14}}
    }
    ```
  """
  def create(wallet_id, transaction) do
    case Backend.create_transaction(wallet_id, transaction) do
      {:ok, transaction} -> {:ok, Util.keys_to_atom(transaction)}
      {:error, message} -> {:error, message}
    end
  end

  @spec list(String.t(),
          start: String.t(),
          stop: String.t(),
          order: atom(),
          min_withdrawal: non_neg_integer()
        ) ::
          {:error, String.t()} | {:ok, list(transaction())}
  @doc """
  Lists all incoming and outgoing wallet's transactions.

  ## Options
    * `start` - An optional start time in ISO 8601 date-and-time format. Basic and extended formats are both accepted. Times can be local (with a timezone offset) or UTC. If both a start time and an end time are specified, then the start time must not be later than the end time. Example: `2008-08-08T08:08:08Z`
    * `stop` - An optional end time in ISO 8601 date-and-time format. Basic and extended formats are both accepted. Times can be local (with a timezone offset) or UTC. If both a start time and an end time are specified, then the start time must not be later than the end time.
    * `order` - Can be set to `:descending` or `:ascending`. Defaults to `:descending`
    * `min_withdrawal` - Returns only transactions that have at least one withdrawal above the given amount. This is particularly useful when set to `1` in order to list the withdrawal history of a wallet.
  """
  def list(wallet_id, options \\ []) do
    default = [
      start: nil,
      stop: nil,
      order: :descending,
      min_withdrawal: nil
    ]

    opts = Enum.into(Keyword.merge(default, options), %{})

    case Backend.list_transactions(
           wallet_id,
           opts.start,
           opts.stop,
           opts.order,
           opts.min_withdrawal
         ) do
      {:ok, transactions} -> {:ok, Enum.map(transactions, fn t -> Util.keys_to_atom(t) end)}
      {:error, message} -> {:error, message}
    end
  end

  @spec get(String.t(), String.t()) :: {:error, String.t()} | {:ok, transaction()}
  @doc """
  Get transaction by id.

  ## Options
    * `transaction_id` - Transaction ID
  """
  def get(wallet_id, transaction_id) do
    case Backend.get_transaction(wallet_id, transaction_id) do
      {:ok, transaction} -> {:ok, Util.keys_to_atom(transaction)}
      {:error, message} -> {:error, message}
    end
  end
end
