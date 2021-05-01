defmodule Cardanoex.NetworkTest do
  use ExUnit.Case
  doctest Cardanoex.Network
  alias Cardanoex.Network

  describe "information" do
    test "fetch information successfully" do
      {:ok, information} = Network.information()
      assert information.node_era == "mary"
    end
  end

  describe "clock" do
    test "fetch clock successfully" do
      {:ok, clock} = Network.clock()
      assert clock.status == "available"
    end
  end

  describe "parameters" do
    test "fetch parameters successfully" do
      {:ok, clock} = Network.parameters()
      assert clock.genesis_block_hash == "96fceff972c2c06bd3bb5243c39215333be6d56aaf4823073dca31afe5038471"
    end
  end
end
