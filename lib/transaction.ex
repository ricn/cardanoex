defmodule Cardanoex.Transaction do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @moduledoc """
  The Transaction module lets you work with transactions for a wallet.
  """

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

  def get(wallet_id, transaction_id) do
    case Backend.get_transaction(wallet_id, transaction_id) do
      {:ok, transaction} -> {:ok, Util.keys_to_atom(transaction)}
      {:error, message} -> {:error, message}
    end
  end
end
