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
