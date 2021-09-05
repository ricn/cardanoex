defmodule Cardanoex.StakePoolTest do
  use ExUnit.Case
  doctest Cardanoex.StakePool
  alias Cardanoex.StakePool

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    [wallet: TestHelpers.setup_wallet_with_funds()]
  end

  describe "list stake pools" do
    test "list stake pools successfully" do
      use_cassette "list_stake_pools_successfully" do
        {:ok, stake_pools} = StakePool.list(10_000 * 1_000_000)
        assert length(stake_pools) == 845
      end
    end
  end

  describe "list stake keys" do
    test "list stake keys successfully", %{wallet: wallet} do
      use_cassette "list_stake_keys_successfully" do
        {:ok, stake_keys} = StakePool.list_stake_keys(wallet.id)
        assert stake_keys != nil
      end
    end
  end

  describe "view maintenance actions" do
    test "view maintenance actions successfully" do
      use_cassette "view_maintenance_actions_successfully" do
        {:ok, maintenance_actions} = StakePool.view_maintenance_actions()
        assert maintenance_actions != nil
      end
    end
  end

  describe "trigger maintenance actions" do
    test "trigger maintenance actions successfully" do
      use_cassette "trigger_maintenance_actions" do
        :ok = StakePool.trigger_maintenance_action("gc_stake_pools")
      end
    end
  end

  describe "estimate fee for joining/leaving stake pool" do
    test "estimate fee for joining/leaving successfully", %{wallet: wallet} do
      use_cassette "estimate_fee_for_joining_stake_pool_successfully" do
        {:ok, estimated_fee} = StakePool.estimate_fee(wallet.id)
        assert estimated_fee.estimated_min != nil
        assert estimated_fee.estimated_max != nil
        assert estimated_fee.minimum_coins != nil
        assert estimated_fee.deposit != nil
      end
    end
  end

  describe "join stake pool" do
    test "join stake pool successfully", %{wallet: wallet} do
      use_cassette "join_stake_pool_successfully" do
        stake_pool_id = "pool1aqr0p4g9zmks8lvkdhe8qpff76jhy8ggl4pen3aa34ftwfegr8x"
        passphrase = "Super_Sekret3.14!"
        {:ok, result} = StakePool.join(wallet.id, stake_pool_id, passphrase)
        assert result.id != nil
      end
    end
  end

  describe "quit staking" do
    test "quit staking", %{wallet: wallet} do
      use_cassette "quit_staking" do
        passphrase = "Super_Sekret3.14!"
        {:error, message} = StakePool.quit(wallet.id, passphrase)
        assert message == "It seems that you're trying to retire from delegation although you've unspoiled rewards in your rewards account! Make sure to withdraw your 7022041 lovelace first."
      end
    end
  end
end
