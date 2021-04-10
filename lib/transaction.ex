defmodule Cardano.Transaction do
  alias Cardano.Backend
  alias Cardano.Util

  def estimate_fee(wallet_id, transaction) do
    case Backend.estimate_transaction_fee(wallet_id, transaction) do
      {:ok, wallet} -> {:ok, Util.keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end
end
