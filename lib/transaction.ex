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

  def list(wallet_id) do
    case Backend.list_transactions(wallet_id) do
      {:ok, transactions} -> {:ok, Enum.map(transactions, fn t -> Util.keys_to_atom(t) end)}
      {:error, message} -> {:error, message}
    end
  end
end
