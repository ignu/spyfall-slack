defmodule SpyfallSlack.Adapter do
  def process(message, slack, state), do:
    _process(at_slackbot?(message, slack), message, slack, state)

  defp _process(true, message, slack, state) do
    command = message_body(message[:text], slack)
    _run(command, state)
  end

  defp _process(false, message, slack, state) do
    Dict.merge state, %{response: nil }
  end

  defp _run("start", %{started: true} = state), do:
    Dict.merge(state, %{response: "Game is already started." })

  defp _run("start", state) do
    Dict.merge state, %{response: "Starting game...", started: true}
  end

  defp _run("join", state) do
    Dict.merge state, %{response: "You're in", started: true}
  end

  defp _run(command, state) do
    Dict.merge state, %{response: "Sorry, I couldn't understand `#{command}`" }
  end

  defp message_body(message, slack) do
    String.strip Regex.replace(bot_regex(slack), message, "")
  end

  defp at_slackbot?(message, slack) do
    text = message[:text]
    Regex.match?(bot_regex(slack), text)
  end

  defp bot_regex(slack) do
    my_id = slack[:me][:id]
    ~r/^<@#{my_id}>/
  end
end
