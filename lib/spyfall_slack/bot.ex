defmodule SpyfallSlack.Bot do
  use Slack
  require IEx

  def start(_type, _args) do
    token = System.get_env("SLACK_BOT_API_TOKEN")
    IO.puts IO.ANSI.underline <> "||||||||| CONNECTED........." <> IO.ANSI.reset
    #pid = spawn(SpyfallSlack.Server, :init, {})
    #initial_state = %{ pid: pid }
    initial_state = {}
    start_link(token, initial_state)
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    IO.puts IO.ANSI.underline <> "|||||||||||||" <> IO.ANSI.reset
    IO.inspect state

    send_message(String.upcase(message.text), message.channel, slack)

    {:ok, state}
  end

  def handle_message(message, _slack, state) do
    IO.inspect message
    {:ok, state}
  end
end
