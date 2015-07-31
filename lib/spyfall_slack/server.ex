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
  def start!(state) do
    start_game(state, Enum.count(state.players) > 2)
  end

  def add_player(_name, state =%{stage: :playing}) do
    { :error, "You need more players!", state }
  end

  @doc """
  Add a player. Games must have three or more players. (Less than seven
  is recommended"
  """
  def add_player(name, state) do
    { :ok, %{ players: state.players ++ [name] } }
  end

  @doc "Return all non-spies"
  def agents(state) do
    { :ok, state.players -- [state.spy], state}
  end

  @doc "Start a vote for a suspected spy. sets susepct in state."
  def accuse!(suspect, state) do
    accused = Enum.find(state.players, nil, fn p -> p == suspect end)
    accused |> start_accusation(state)
  end

  defp start_accusation(nil, state) do
    { :error, "You must accuse a valid player", state }
  end

  defp start_accusation(suspect, state) do
    state = Dict.put(state, :suspect, suspect)
    { :ok, state }
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
