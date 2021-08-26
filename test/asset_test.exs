defmodule Cardanoex.AssetTest do
  use ExUnit.Case
  doctest Cardanoex.Asset
  alias Cardanoex.Asset

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    [wallet: TestHelpers.setup_wallet_with_funds()]
  end

  describe "list assets" do
    test "list assets successfully", %{wallet: wallet} do
      use_cassette "list_assets_successfully" do
        {:ok, assets} = Asset.list(wallet.id)
        assert length(assets) == 1
      end
    end

    test "try list assets with invalid wallet id" do
      use_cassette "try_list_assets_with_invalid_wallet_id" do
        {:error, message} = Asset.list("abc-123")
        assert "wallet id should be a hex-encoded string of 40 characters" == message
      end
    end

    test "try list assets with correctly formatted id but non existent" do
      use_cassette "try_list_assets_with_correctly_formatted_id_but_non_existent" do
        {:error, message} = Asset.list("511b0ff88918401c119d3c6ccd4156e53444b5f0")

        assert "I couldn't find a wallet with the given id: 511b0ff88918401c119d3c6ccd4156e53444b5f0" ==
                message
      end
    end
  end

  describe "get asset" do
    test "get asset successfully", %{wallet: wallet} do
      use_cassette "get_asset_successfully" do
        policy_id = "6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7"
        {:ok, asset} = Asset.get(wallet.id, policy_id)
        assert asset.fingerprint == "asset1cvmyrfrc7lpht2hcjwr9lulzyyjv27uxh3kcz0"
      end
    end

    ## TODO: Add more here after we have minted some cool coins with names n shit
  end

  describe "mint / burn asset" do
    test "mint 1000 beer coins successfully", %{wallet: wallet} do
      use_cassette "mint_beer_coins_successfully" do
        mint = %{
          mint_burn: [
            %{
              monetary_policy_index: 0, # TODO: What's this?
              asset_name: "Beer coin",
              operation: %{
                mint: %{
                  receiving_address: "addr_test1qq0306kjm9zx60zmgs9ch4anupfwscju3xxs0gp2csze8f4psnaecl02hhx2mr6f3lz3xyfen9hvypqpxf34a5gzvx3q2fgp4a",
                  amount: %{
                    quantity: 1000,
                    unit: "beers"
                  }
                }
              }
            }
          ],
          passphrase: "Super_Sekret3.14!"
        }

        {:ok, transaction} = Asset.mint_burn(wallet.id, mint)
        IO.inspect transaction
        assert transaction != nil
      end
    end
  end
end
