defmodule Cardanoex.Network do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  @moduledoc """
  The Network module helps you check various information and parameters in the network
  """

  @type network_information :: %{
          sync_process: %{
            status: String.t(),
            progress: %{
              quantity: 0..100,
              unit: String.t()
            }
          },
          node_tip: %{
            absolute_slot_number: non_neg_integer(),
            slot_number: non_neg_integer(),
            epoch_number: non_neg_integer(),
            time: String.t(),
            height: %{
              quantity: non_neg_integer(),
              unit: String.t()
            }
          },
          network_tip: %{
            absolute_slot_number: non_neg_integer(),
            slot_number: non_neg_integer(),
            epoch_number: non_neg_integer(),
            time: String.t()
          },
          next_epoch: %{
            epoch_number: non_neg_integer(),
            epoch_start_time: String.t()
          },
          node_era: String.t()
        }

  @type clock :: %{
          status: String.t(),
          offset: %{
            quantity: integer(),
            unit: String.t()
          }
        }

  @type parameters :: %{
          slot_length: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          decentralization_level: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          maximum_token_bundle_size: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          genesis_block_hash: String.t(),
          blockchain_start_time: String.t(),
          desired_pool_number: non_neg_integer(),
          epoch_length: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          eras: map(),
          active_slot_coefficient: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          security_parameter: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          minimum_utxo_value: %{
            quantity: non_neg_integer(),
            unit: String.t()
          },
          maximum_collateral_input_count: non_neg_integer()
        }

  @spec information :: {:error, String} | {:ok, network_information}
  @doc """
  Get information about the network.
  """
  def information do
    case Backend.network_information() do
      {:ok, information} -> {:ok, Util.keys_to_atom(information)}
      {:error, message} -> {:error, message}
    end
  end

  @spec clock :: {:error, String.t()} | {:ok, clock}
  @doc """
  Get network clock information.
  """
  def clock do
    case Backend.network_clock() do
      {:ok, clock} -> {:ok, Util.keys_to_atom(clock)}
      {:error, message} -> {:error, message}
    end
  end

  @spec parameters :: {:error, String.t()} | {:ok, parameters}
  @doc """
  Get network parameters.
  """
  def parameters do
    case Backend.network_parameters() do
      {:ok, parameters} -> {:ok, Util.keys_to_atom(parameters)}
      {:error, message} -> {:error, message}
    end
  end
end
