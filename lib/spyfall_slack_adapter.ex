defmodule SpyfallSlack.Adapter do
  alias SpyfallSlack.Server

  def process(message, slack, state), do:
    _process(at_slackbot?(message, slack), message, slack, state)

  defp _process(true, message, slack, state) do
    command = message_body(message[:text], slack)
    user = user_name(message[:user], slack)
    state = Dict.merge state, %{response: nil, user: user }
    _run(command, state)
  end

  defp _process(false, message, slack, state) do
    Dict.merge state, %{response: nil }
  end

  defp _run("start", %{started: true} = state), do:
    Dict.merge(state, %{response: "Game is already started." })

  defp _run("start", state) do
    _run Server.start(state)
  end

  defp _run({:error, state}) do
    Dict.merge(state, %{response: "Game is already started." })
  end

  defp _run({:ok, state}) do
    Dict.merge(state, %{response: "Game is already started." })
  end

  defp _run("join", state) do
    user = state[:user]
    found_user = state[:users][user]
    _add_user(user, found_user, state)
  end

  defp _run(command, state) do
    Dict.merge state, %{response: "Sorry, I couldn't understand `#{command}`" }
  end

  defp _add_user(user, nil, state) do
    users = state[:users] || %{}
    users = Dict.put users, user, %{}
    Dict.merge state, %{response: "#{user}, you're in.", users: users}
  end

  defp _add_user(user, found_user, state) do
    Dict.merge state, %{response: "yes, #{user}, you're already in!", started: true}
  end

  defp message_body(message, slack) do
    String.strip Regex.replace(bot_regex(slack), message, "")
  end

  defp at_slackbot?(message, slack) do
    text = message[:text]
    Regex.match?(bot_regex(slack), text)
  end

  defp user_name(user_id, slack) do
    slack[:users][user_id][:name]
  end

  defp bot_regex(slack) do
    my_id = slack[:me][:id]
    ~r/^<@#{my_id}>/
  end
end
