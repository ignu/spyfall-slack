defmodule SpyfallSlack.Bot do
  use Slack
  require IEx

  def start(_type, _args) do
    token = System.get_env("SLACK_BOT_API_TOKEN")
    initial_state = %{}
    start_link(token, initial_state)
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    user = get_username(message.user, slack)

    state = SpyfallSlack.Adapter.process(message, slack, state)

    #TODO, don't send message when there's no response
    send_message(state.response, message.channel, slack)

    {:ok, state}
  end

  defp get_username(id, slack) do
    slack[:users][id].name
  end

  def handle_message(message, _slack, state) do
    IO.inspect message
    {:ok, state}
  end
end
