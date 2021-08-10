defmodule Cardanoex.Transaction do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @moduledoc """
  The Transaction module lets you work with transactions for a wallet.
  """

  @doc """
  Estimate fee for the transaction.
  The estimate is made by assembling multiple transactions and analyzing the distribution of their fees.
  The estimated_max is the highest fee observed, and the estimated_min is the fee which is lower than at least 90% of the fees observed.

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
    ```

  """
  def create(wallet_id, transaction) do
    case Backend.create_transaction(wallet_id, transaction) do
      {:ok, transaction} -> {:ok, Util.keys_to_atom(transaction)}
      {:error, message} -> {:error, message}
    end
  end

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
