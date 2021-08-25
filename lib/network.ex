defmodule Cardanoex.Network do
  alias Cardanoex.Backend
  alias Cardanoex.Util
  @moduledoc """
  The Network module helps you check various information and parameters in the network
  """

  @doc """
  Get information about the network.
  """
  def information do
    case Backend.network_information() do
      {:ok, information} -> {:ok, Util.keys_to_atom(information)}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Get network clock information.
  """
  def clock do
    case Backend.network_clock() do
      {:ok, clock} -> {:ok, Util.keys_to_atom(clock)}
      {:error, message} -> {:error, message}
    end
  end

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
