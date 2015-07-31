defmodule SpyfallSlack.ServerTest do
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
    assert state.stage == :playing

    #TODO: mock random and do better test?
    assert state.spy != nil
    assert state.location != nil
  end

  test "can not start a game with < 3 players" do
    state = %{ players: ["a", "b"] }
    { :error, message, _state } = SpyfallSlack.Server.start!(state)
    assert message != nil
  end

  test "can not add players once the game is started" do
    state = %{ players: ["a", "b"], stage: :playing }
    { :error, message, _state } = SpyfallSlack.Server.add_player('bill', state)
    assert message != nil
  end

  test "can get a list of spies" do
    state = %{ players: ["a", "b", "c"], spy: "c", stage: :playing }
    { :ok, agents, _state } = SpyfallSlack.Server.agents(state)
    assert agents == ["a", "b"]
  end

  test "accusing sets a suspect" do
    state = %{ players: ["a", "b", "c"], spy: "c", stage: :playing }
    { :ok, state } = SpyfallSlack.Server.accuse!("a", state)
    # ? assert state.stage == :voting
    assert state.suspect == "a"
  end

  test "error when accusing a non-player" do
    state = %{ players: ["a", "b", "c"], spy: "c", stage: :playing }
    { :error, message, _state } = SpyfallSlack.Server.accuse!("x", state)

    assert message != nil
  end
end
