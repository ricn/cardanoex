defmodule Cardanoex.TransactionTest do
  use ExUnit.Case
  doctest Cardanoex.Transaction
  alias Cardanoex.Transaction
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

    test "try estimate fee with 1 lovelace", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1, unit: "lovelace"}
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      expected_message =
        "Some outputs have ada values that are too small. There's a minimum ada value specified by the protocol that each output must satisfy. I'll handle that minimum value myself when you do not explicitly specify an ada value for an output. Otherwise, you must specify enough ada. Here are the problematic outputs:   - Expected min coin value: 1.000000     TxOut:       address: 00f8227b...6e607d73       coin: 0.000001       tokens: [] "

      assert expected_message == message
    end

    test "try estimate fee with no payments", %{wallet: wallet} do
      transaction = %{
        payments: []
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      expected_message = "Error in $.payments: parsing NonEmpty failed, unexpected empty list"
      assert expected_message == message
    end

    test "estimate fee with assets included", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"},
            assets: [
              %{
                policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7",
                asset_name: "",
                quantity: 1
              }
            ]
          }
        ]
      }

      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
      assert estimated_fees != nil
    end

    test "try estimate fee with too low amount of ada", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 0_407_406, unit: "lovelace"},
            assets: [
              %{
                policy_id: "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7",
                asset_name: "",
                quantity: 1
              }
            ]
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      assert "Some outputs have ada values that are too small. There's a minimum ada value specified by the protocol that each output must satisfy. I'll handle that minimum value myself when you do not explicitly specify an ada value for an output. Otherwise, you must specify enough ada. Here are the problematic outputs:   - Expected min coin value: 1.407406     TxOut:       address: 00f8227b...6e607d73       coin: 0.407406       tokens:         - policy: 6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7           tokens:             - token:               quantity: 1 " ==
               message
    end

    test "try estimate fee with too low amount of test asset", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
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

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      assert "Error in $.payments[0].assets: parsing AddressAmount failed, Error while deserializing token map from JSON: Encountered zero-valued quantity for token '' within policy '6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7'." ==
               message
    end

    test "try estimate fee with invalid policy id", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"},
            assets: [
              %{
                policy_id: "7a8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7",
                asset_name: "",
                quantity: 1
              }
            ]
          }
        ]
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      assert "I can't process this payment as there are not enough funds available in the wallet. I am missing: coin: 0.000000 tokens:   - policy: 7a8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7     token:     quantity: 1 " ==
               message
    end

    test "estimate fee with metadata", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"}
          }
        ],
        metadata: %{"0" => %{"string" => "cardano"}, "1" => %{"int" => 14}}
      }

      {:ok, estimated_fees} = Transaction.estimate_fee(wallet.id, transaction)
      estimated_max = estimated_min = 168_801
      assert estimated_fees.estimated_max.quantity > estimated_max
      assert estimated_fees.estimated_min.quantity > estimated_min
    end

    test "try estimate fee with metadata not containing an unsigned integer key at the top level",
         %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"}
          }
        ],
        metadata: %{"cardano" => %{"string" => "cardano"}, "1" => %{"int" => 14}}
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      assert "Error in $.metadata: The JSON metadata top level must be a map (JSON object) with unsigned integer keys. Invalid key: 'cardano'" ==
               message
    end

    test "try estimate fee with metadata containing too long string", %{wallet: wallet} do
      transaction = %{
        payments: [
          %{
            address:
              "addr_test1qruzy7l5nhsuckunkg6mmu2qyvgvesahfxmmymlzc78qur5ylvf75ukft7actuxlj0sqrkkerrvfmcnp0ksc6mnq04es9elzy7",
            amount: %{quantity: 1_407_406, unit: "lovelace"}
          }
        ],
        metadata: %{"0" => %{"string" => String.duplicate("a", 65)}, "1" => %{"int" => 14}}
      }

      {:error, message} = Transaction.estimate_fee(wallet.id, transaction)

      assert "Error in $.metadata: Value out of range within the metadata item 0: {'string':'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} Text string metadata value must consist of at most 64 UTF8 bytes, but it consists of 65 bytes." ==
               message
    end
  end

  describe "create transaction" do
    test "create transaction successfully", %{wallet: wallet} do
      transaction = %{
        passphrase: "Super_Sekret3.14!",
        payments: [
          %{
            address:
              "addr_test1qqt6c697uderxaccgnerhhmp6yf2kctj0zpxkmjxvuger3sgcw2hdh4qrckpls3aq7kq8ma8pwsyzct0e6ndeadm64dsuzfj8f",
            amount: %{quantity: 1_000_000, unit: "lovelace"}
          }
        ]
      }

      {:ok, transaction} = Transaction.create(wallet.id, transaction)
      assert transaction != nil
    end

    test "try create transaction with invalid passphrase", %{wallet: wallet} do
      transaction = %{
        passphrase: "Bad",
        payments: [
          %{
            address:
              "addr_test1qqt6c697uderxaccgnerhhmp6yf2kctj0zpxkmjxvuger3sgcw2hdh4qrckpls3aq7kq8ma8pwsyzct0e6ndeadm64dsuzfj8f",
            amount: %{quantity: 1_000_000, unit: "lovelace"}
          }
        ]
      }

      {:error, message} = Transaction.create(wallet.id, transaction)

      assert "The given encryption passphrase doesn't match the one I use to encrypt the root private key of the given wallet: 5c70f4f4970cadb7d5ec927e634be355df964b52" ==
               message
    end

    test "create transaction successfully with metadata", %{wallet: wallet} do
      transaction = %{
        passphrase: "Super_Sekret3.14!",
        payments: [
          %{
            address:
              "addr_test1qqt6c697uderxaccgnerhhmp6yf2kctj0zpxkmjxvuger3sgcw2hdh4qrckpls3aq7kq8ma8pwsyzct0e6ndeadm64dsuzfj8f",
            amount: %{quantity: 1_407_406, unit: "lovelace"}
          }
        ],
        metadata: %{"0" => %{"string" => "cardano"}, "1" => %{"int" => 14}}
      }

      {:ok, transaction} = Transaction.create(wallet.id, transaction)
      assert transaction != nil
    end

    test "try create transaction with invalid metadata", %{wallet: wallet} do
      transaction = %{
        passphrase: "Super_Sekret3.14!",
        payments: [
          %{
            address:
              "addr_test1qqt6c697uderxaccgnerhhmp6yf2kctj0zpxkmjxvuger3sgcw2hdh4qrckpls3aq7kq8ma8pwsyzct0e6ndeadm64dsuzfj8f",
            amount: %{quantity: 1_407_406, unit: "lovelace"}
          }
        ],
        metadata: %{"cardano" => %{"string" => "cardano"}, "1" => %{"int" => 14}}
      }

      {:error, message} = Transaction.create(wallet.id, transaction)

      assert "Error in $.metadata: The JSON metadata top level must be a map (JSON object) with unsigned integer keys. Invalid key: 'cardano'" ==
               message
    end
  end

  describe "list transactions" do
    test "list transactions successfully", %{wallet: wallet} do
      {:ok, transactions} = Transaction.list(wallet.id)
      assert is_list(transactions)
    end

    test "list transactions in ascending order", %{wallet: wallet} do
      {:ok, transactions_asc} = Transaction.list(wallet.id, order: :ascending)
      {:ok, transactions_desc} = Transaction.list(wallet.id, order: :descending)

      assert Enum.reverse(transactions_asc) == transactions_desc
    end

    test "list transactions from a specific date", %{wallet: wallet} do
      {:ok, transactions} =
        Transaction.list(wallet.id, start: "2021-04-12T00:00:00Z", stop: "2021-04-12T23:59:59Z")

      assert length(transactions) == 2
    end

    test "list transactions with min withdrawal of 1", %{wallet: wallet} do
      {:ok, transactions} = Transaction.list(wallet.id, min_withdrawal: 1)
      # TODO:
      assert length(transactions) == 0
    end
  end

  describe "get transaction" do
    test "get transaction successfully", %{wallet: wallet} do
      transaction_id = "1c71514d379a13c87e830c4e1d569e551abc4eddebee42ddf86d348712c99d35"
      {:ok, transaction} = Transaction.get(wallet.id, transaction_id)
      assert transaction_id == transaction.id
    end

    test "try get transaction that does not exists", %{wallet: wallet} do
      transaction_id = "2d82614d379a13c87e430c4e1d569e551abc4abbebee42ddf86d348712c88c24"
      {:error, message} = Transaction.get(wallet.id, transaction_id)

      assert "I couldn't find a transaction with the given id: 2d82614d379a13c87e430c4e1d569e551abc4abbebee42ddf86d348712c88c24" ==
               message
    end
  end
end
