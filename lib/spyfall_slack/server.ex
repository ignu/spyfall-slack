defmodule SpyfallSlack.Server do
  defstruct players: [], spy: nil, location: nil, stage: :started

  def init do
    { :ok, %SpyfallSlack.Server{} }
  end

  @doc """
  Start the game. Once a game is started, roles and location are assigned
  and you can no longer call add_player.

  A location is set randomly, as well as a spy from the list of players
  """
  def start(state) do
    start_game(state, Enum.count(state.players) > 2)
  end

  def add_player(_name, state =%{stage: :playing}) do
    { :error, "You need more players!", state }
  end

  @doc """
  Add a player. Games must have three or more players. (Less than seven
  is recommended)"
  """
  def add_player(name, state) do
    { :ok, %{ players: state.players ++ [name] } }
  end

  @doc "Return all non-spies"
  def agents(state) do
    state.players -- [state.spy]
  end

  @doc """
  Start a vote for a suspected spy.
  Sets suspect in state and creates a list of accusers.
  """
  def accuse(accuser, suspect, state) do
    start_accusation(fetch(accuser, state), fetch(suspect, state), state)
  end

  @doc """
  A vote for the current accused
  """
  def vote(voter, value, state) do
    cond do
      voter == state.suspect ->
        { :error, "#{voter} is the suspect and can not vote", state }
      true ->
        _vote(voter, value, state)
    end
  end

  @doc """
  A spy's guess of the current location
  """
  def guess(location, state) do
    cond do
      state.stage == :victory ->
        { :error, "Too late. Game over.", state }
      Enum.any? locations, &(&1 == location) ->
        _guess(location == state.location, state)
      true ->
        l = locations |> Enum.join(", ")

        { :error,
          "'#{location}' is not an option. Guess one of [#{l}]",
          %{ state | stage: :guess }
        }
    end
  end

  def _guess(true, s) do
    { :ok, "", %{ s | stage: :loss } }
  end

  def _guess(false, s) do
    { :ok, "", %{ s | stage: :victory } }
  end

  defp fetch(player, state) do
    Enum.find(state.players, nil, &(&1 == player))
  end

  defp _vote(voter, false, state) do
    state = state |> Dict.merge %{
      stage: :playing,
      accusers: [],
      suspect: nil
    }

    { :ok, "#{voter} doesn't think #{state.suspect} is a spy. Resume playing.", state }
  end

  defp _vote(voter, true, state) do
    state = %{ state | accusers: state.accusers ++ [voter]}
    agent_count = Enum.count(state.players) - 1
    message = ""

    cond do
      # if all spies have guessed correctly
      (agents(state) -- state.accusers) == [] ->
        state =  %{ state | stage: :guess }

      # if all votes are for the wrong person
      Enum.count(state.accusers) == agent_count ->
        message = "Agents lose! #{state.spy} was actually the spy"
        state = %{ state | stage: :loss }

      true ->
    end

    { :ok, message, state }
  end

  defp start_accusation(nil, _suspect, state) do
    { :error, "Not a valid player", state }
  end

  defp start_accusation(_accuser, nil, state) do
    { :error, "You must accuse a valid player", state }
  end

  defp start_accusation(accuser, suspect, state) do
    state = Dict.put(state, :accusers, [accuser])
    state = Dict.put(state, :suspect, suspect)
    { :ok, %{ state | stage: :accusing } }
  end

  defp start_game(state, false) do
    { :error, "You need more players!", state }
  end

  defp start_game(state, _valid) do
    :random.seed(:os.timestamp)

    spy = state.players |> Enum.shuffle |> hd
    location = locations |> Enum.shuffle |> hd

    state = Dict.merge state, %{
      spy: spy,
      stage: :playing,
      location: location }

    { :ok, state }
  end

  defp locations do
    [
      "Submarine",
      "Casino",
      "Police Station",
      "Shoping Mall Food Court",
      "Airport",
      "Elementary School",
      "Prison",
      "Bank",
      "Theater",
      "Pirate Ship",
      "Passenger Train",
      "Day Spa",
      "Movie Studio",
      "Ocean Liner",
      "Beach",
      "Restaurant",
      "Space Station",
      "Corporate Holiday Party",
      "Supermarket"
    ]
  end
end
