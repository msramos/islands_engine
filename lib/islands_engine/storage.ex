defmodule IslandsEngine.Storage do
  @moduledoc """
  Storage handling for the engine. Stores key/values on ETS
  """
  @ets_table __MODULE__

  @doc """
  Initializes the storage by creating the ETS table
  """
  def init do
    :ets.new(@ets_table, [:public, :named_table])
  end

  @doc """
  Stores a value with the given key
  """
  @spec store(any(), any()) :: true
  def store(key, value) do
    :ets.insert(@ets_table, {key, value})
  end

  @doc """
  Deletes the value registered with the given key
  """
  @spec delete(any()) :: true
  def delete(key) do
    :ets.delete(@ets_table, key)
  end

  @doc """
  Fetches the value registered with the given key.
  """
  @spec fetch(any()) :: {:ok, any()} | {:error, :not_found}
  def fetch(key) do
    case :ets.lookup(@ets_table, key) do
      [] ->
        {:error, :not_found}

      [{_key, state}] ->
        {:ok, state}
    end
  end
end
