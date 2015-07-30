defmodule SpyfallSlack.Server do
  def init do
    { :ok, %{ players: [] } }
  end

  def add_player(name, state) do
    { :ok, %{ players: state.players ++ [name] } }
  end

  def start!(state) do
    start_game(state, Enum.count(state.players) > 2)
  end

  defp start_game(state, false) do # HACK: why doesn't this work: when length(players < 3) do
    { :error, "You need more players!", state }
  end

  defp start_game(state, _valid) do
    spy = "" #TODO, randomize spy out of players
    { :ok, Dict.put(state, :spy, spy) }
  end
end

