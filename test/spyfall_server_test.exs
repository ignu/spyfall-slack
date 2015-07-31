defmodule SpyfallServer do
  use ExUnit.Case

  test "can queue up players" do
    { :ok, state } = SpyfallSlack.Server.init
    { :ok, state } = SpyfallSlack.Server.add_player("ned", state)
    { :ok, state } = SpyfallSlack.Server.add_player("jon", state)

    assert state.players == ["ned", "jon"]
  end

  test "can start a game with > 2 players" do
    state = %{ players: ["a", "b", "c"], stage: :started }
    { :ok, state } = SpyfallSlack.Server.start!(state)
    assert state.spy != nil
    assert state.stage == :playing
  end

  test "can not start a game with < 3 players" do
    state = %{ players: ["a", "b"] }
    { :error, message, state } = SpyfallSlack.Server.start!(state)
    assert message != nil
  end

  test "can not add players once the game is started" do
    state = %{ players: ["a", "b"], stage: :playing }
    { :error, message, state } = SpyfallSlack.Server.add_player('bill', state)
    assert message != nil
  end
end
