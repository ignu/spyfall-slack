defmodule SpyfallSlackAdapterTest do
  use ExUnit.Case
  alias SpyfallSlack.Adapter

  @bot_id "U08BMDLQ4"
  @me_id "U08BDN6Q4"

  def slack(overrides) do
    %{
      me: %{ id: @bot_id },
      users: %{
        @bot_id => %{ id: @bot_id, name: "spyfall" },
        @me_id => %{ id: @me_id, name: "ignu" }
      }
    } |> Dict.merge(overrides)
  end

  def at_slackbot(message \\ %{}) do
    %{channel: "C08BDN6R2", team: "T08BDN6P6", text: "<@#{@bot_id}> hi",
      ts: "1438664826.000027", type: "message", user: @me_id} |> Dict.merge(message)
  end

  test "a nil message is a passthrough" do
    state = Adapter.process(%{ text: "<>" }, slack(%{}), %{})
    assert state.response == nil
  end

  test "an un-understood message to the bot gets a response" do
    state = Adapter.process(at_slackbot, slack(%{}), %{})
    assert "Sorry, I couldn't understand `hi`" == state.response
  end

  test "starting a game" do
    state = Adapter.process(%{ at_slackbot | text: "<@#{@bot_id}> start"}, slack(%{}), %{})

    assert "Starting game..." == state.response
  end

  test "starting a game that's already started" do
    state = Adapter.process(%{ at_slackbot | text: "<@#{@bot_id}> start"}, slack(%{}), %{})
    state = Adapter.process(%{ at_slackbot | text: "<@#{@bot_id}> start"}, slack(%{}), state)

    assert "Game is already started." == state.response
  end

  test "adding players" do
    state = Adapter.process(%{ at_slackbot | text: "<@#{@bot_id}> join"}, slack(%{}), %{})

    assert "ignu, you're in." == state.response

    state = Adapter.process(%{ at_slackbot | text: "<@#{@bot_id}> join"}, slack(%{}), state)
    assert "yes, ignu, you're already in!" == state.response
  end

  test "accuse a player" do
  end

  test "vote on a accusation" do
  end

  test "guess a location as a spy" do
  end
end
