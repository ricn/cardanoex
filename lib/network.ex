defmodule Cardanoex.Network do
  alias Cardanoex.Backend
  alias Cardanoex.Util

  def information do
    case Backend.network_information() do
      {:ok, information} -> {:ok, Util.keys_to_atom(information)}
      {:error, message} -> {:error, message}
    end
  end

  def clock do
    case Backend.network_clock() do
      {:ok, clock} -> {:ok, Util.keys_to_atom(clock)}
      {:error, message} -> {:error, message}
    end
  end

  def parameters do
    case Backend.network_parameters() do
      {:ok, parameters} -> {:ok, Util.keys_to_atom(parameters)}
      {:error, message} -> {:error, message}
    end
  end

end
