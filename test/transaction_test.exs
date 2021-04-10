defmodule Cardano.TransactionTest do
  use ExUnit.Case
  doctest Cardano.Transaction
  alias Cardano.Transaction
  alias TestHelpers

  setup_all do
    [wallet: TestHelpers.setup_wallet_with_funds()]
  end

  describe "estimate fee" do
    test "estimate fee successfully", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 42_000_000, unit: "lovelace"}
          }
        ]
      }

      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
      assert estimated_fees != nil
    end
  end
end
