defmodule SpyfallSlack.Server do
  def init do
    { :ok, %{ players: [] } }
  end

  def add_player(name, state) do
    { :ok, %{ players: state.players ++ [name] } }
  end

  def start!(state) do
    spy = "" #TODO, randomize spy out of players
    { :ok, Dict.put(state, :spy, spy) }
  end
end

