defmodule SpyfallServer do
  use ExUnit.Case

  test "can queue up players" do
    { :ok, state } = SpyfallSlack.Server.init
    { :ok, state } = SpyfallSlack.Server.add_player("ned", state)
    { :ok, state } = SpyfallSlack.Server.add_player("jon", state)

    assert state.players == ["ned", "jon"]
  end

  test "cant start a game with < 4 players" do
    state = %{ players: ["a", "b"] }
    { :ok, state } = SpyfallSlack.Server.start!(state)
    assert state.spy != nil
  end
end
