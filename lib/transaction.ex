defmodule Cardano.Transaction do
  alias Cardano.Backend

  def estimate_fee(wallet_id, transaction) do
    Backend.estimate_transaction_fee(wallet_id, transaction)
  end
end
