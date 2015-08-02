defmodule SpyfallSlack.ServerTest do
  use ExUnit.Case
  alias SpyfallSlack.Server

  test "can queue up players" do
    { :ok, state } = Server.init
    { :ok, state } = Server.add_player("ned", state)
    { :ok, state } = Server.add_player("jon", state)

    assert state.players == ["ned", "jon"]
  end

  test "can start a game with > 2 players" do
    state = %{ players: ["a", "b", "c"], stage: :started }
    { :ok, state } = Server.start(state)
    assert state.stage == :playing

    #TODO: mock random and do better test?
    assert state.spy != nil
    assert state.location != nil
  end

  test "can not start a game with < 3 players" do
    state = %{ players: ["a", "b"] }
    { :error, message, _state } = Server.start(state)
    assert message != nil
  end

  test "can not add players once the game is started" do
    state = %{ players: ["a", "b"], stage: :playing }
    { :error, message, _state } = Server.add_player('bill', state)
    assert message != nil
  end

  test "can get a list of spies" do
    state = %{ players: ["a", "b", "c"], spy: "c", stage: :playing }
    agents = Server.agents(state)
    assert agents == ["a", "b"]
  end

  test "accusing sets a suspect" do
    state = %{ players: ["a", "b", "c"], spy: "c", stage: :playing }
    { :ok, state } = Server.accuse("b", "a", state)
    assert state.stage == :accusing
    assert state.suspect == "a"
    assert state.accusers == ["b"]
  end

  test "error when accusing a non-player" do
    state = %{ players: ["a", "b", "c"], spy: "c", stage: :playing }
    { :error, message, _state } = Server.accuse("a", "x", state)

    assert message != nil
  end

  test "players can vote true" do
    state = %{ players: ["a", "b", "c", "d"],
               spy: "c",
               suspect: "c",
               accusers: ["a"],
               stage: :accusing }

    { :ok, _message, state } = Server.vote("d", true, state)
    assert state.stage == :accusing

    { :ok, _message, state } = Server.vote("b", true, state)
    assert state.stage == :guess
  end

  test "players can vote false" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               suspect: "c",
               accusers: ["a"],
               stage: :accusing }

    { :ok, _message, state } = Server.vote("b", false, state)

    assert state.stage == :playing
    assert state.accusers == []
    assert state.suspect == nil
  end

  test "accused can not vote" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               suspect: "c",
               accusers: ["a"],
               stage: :accusing }

    { :error, _message, state } = Server.vote("c", false, state)
    assert state.stage == :accusing
  end

  test "game is over if everyone votes for the wrong person" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               suspect: "b",
               accusers: ["a"],
               stage: :accusing }

    { :ok, _message, state } = Server.vote("c", true, state)
    assert state.stage == :loss
  end

  test "spy wins if they guess correctly" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               location: "Beach",
               stage: :playing }

    { :ok, _message, state } = Server.guess("Beach", state)
    assert state.stage == :loss
  end

  test "agents win if spy guesses incorrectly" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               location: "Beach",
               stage: :playing }

    { :ok, _message, state } = Server.guess("Prison", state)
    assert state.stage == :victory
  end

  test "error message if spy's guess is incomprehensible" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               location: "Beach",
               stage: :playing }

    { :error, _message, state } = Server.guess("Tokyo", state)
    assert state.stage == :guess
  end

  test "a spy can't guess after they lost the game" do
    state = %{ players: ["a", "b", "c"],
               spy: "c",
               location: "Beach",
               stage: :victory }

    { _, _message, state } = Server.guess("Beach", state)
    assert state.stage == :victory
  end

  test "Different endgame permutations - Integration Test" do
    { :ok, s } = Server.init()
    { :ok, s } = Server.add_player("Chief", s)
    { :ok, s } = Server.add_player("Boomer", s)
    { :ok, s } = Server.add_player("Starbuck", s)
    { :ok, s } = Server.start(s)

    # not so integraitony, but have to replace randomized bits
    s = %{ s |  spy: "Boomer", location: "Bank" }

    game_started_state = s

    # Spy Victory
    { :ok, s } = Server.accuse("Chief", "Starbuck", s)
    { :ok, _message, s } = Server.vote("Boomer", true, s)
    assert s.stage == :loss

    # Spy Loss
    { :ok, s } = Server.accuse("Chief", "Boomer", game_started_state)
    { :ok, _message, s } = Server.vote("Starbuck", true, s)
    assert s.stage == :guess
    { :ok, _message, s } = Server.guess("Beach", s)
    assert s.stage == :victory
  end
end
