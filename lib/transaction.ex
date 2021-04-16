defmodule Cardano.Transaction do
  alias Cardano.Backend
  alias Cardano.Util

  def estimate_fee(wallet_id, transaction) do
    case Backend.estimate_transaction_fee(wallet_id, transaction) do
      {:ok, fee_estimation} -> {:ok, Util.keys_to_atom(fee_estimation)}
      {:error, message} -> {:error, message}
    end
  end

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
