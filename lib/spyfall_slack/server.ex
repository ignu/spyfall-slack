defmodule SpyfallSlack.Server do
  defstruct players: [], spy: nil, location: nil, stage: :started

  def init do
    { :ok, %SpyfallSlack.Server{} }
  end

  def add_player(_name, state =%{stage: :playing}) do
    { :error, "You need more players!", state }
  end

  def add_player(name, state) do
    { :ok, %{ players: state.players ++ [name] } }
  end

  def start!(state) do
    start_game(state, Enum.count(state.players) > 2)
  end

  defp start_game(state, false) do
    { :error, "You need more players!", state }
  end

  defp start_game(state, _valid) do
    spy = "" #TODO, randomize spy out of players
    { :ok, Dict.put(Dict.put(state, :spy, spy), :stage, :playing) }
  end
end
