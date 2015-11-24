defmodule SpyfallSlackAdapterTest do
  use ExUnit.Case
  alias SpyfallSlack.Adapter

  @bot_id "U08BMDLQ4"
  @me_id "U08BDN6Q4"
  @miles_id "MILESMORALES"
  @jessica_id "JESSJONES"

  def slack(overrides \\ %{}) do
    %{
      me: %{ id: @bot_id },
      users: %{
        @bot_id => %{ id: @bot_id, name: "spyfall" },
        @me_id => %{ id: @me_id, name: "ignu" },
        @miles_id => %{ id: @miles_id, name: "miles morales" },
        @jessica_id => %{ id: @jessica_id, name: "jessica jones" }
      }
    } |> Dict.merge(overrides)
  end

  def many_users do
    %{
      @me_id => %{ id: @me_id, name: "ignu" },
      @miles_id => %{ id: @miles_id, name: "miles morales" },
      @jessica_id => %{ id: @jessica_id, name: "jessica jones" }
    }
  end

  def at_slackbot(message) when is_binary(message) do
    %{channel: "C08BDN6R2", team: "T08BDN6P6", text: "<@#{@bot_id}> #{message}",
      ts: "1438664826.000027", type: "message", user: @me_id}
  end

  test "a nil message is a passthrough" do
    state = Adapter.process(%{ text: "<>" }, slack, %{})
    assert state.response == nil
  end

  test "an un-understood message to the bot gets a response" do
    state = Adapter.process(at_slackbot("hi"), slack, %{})
    assert "Sorry, I couldn't understand `hi`" == state.response
  end

  test "starting a game" do
    state = Adapter.process(at_slackbot("start"), slack, %{ users: many_users })

    assert "Starting game..." == state.response

    assert state[:users][@me_id].role != nil
  end

  test "starting a game that's already started" do
    state = Adapter.process(at_slackbot("start"), slack, %{users: many_users})
    state = Adapter.process(at_slackbot("start"), slack, state)

    assert "Game is already started." == state.response
  end

  test "starting a game without enough players" do
    state = Adapter.process(at_slackbot("start"), slack, %{})

    assert "We need at least three players to start a game." == state.response
  end

  test "adding players" do
    state = Adapter.process(at_slackbot("join"), slack, %{})

    assert "ignu, you're in." == state.response

    state = Adapter.process(at_slackbot("join"), slack, state)

    assert "yes, ignu, you're already in!" == state.response
  end

  test "accuse a player" do
    #state = %{users: many_users, started: true}
    #state = Adapter.process(at_slackbot("start"), slack, state)
  end

  test "accuse a non-player" do
  end

  test "vote on a accusation" do
  end

  test "guess a location as a spy" do
  end
end
