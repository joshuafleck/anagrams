defmodule AnagramsWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def handle_in("search", word, socket) do
    {duration, matches} = Timex.Duration.measure(fn ->
      find_anagrams(word)
    end)

    result = %{
      "requestedAt" => DateTime.to_iso8601(DateTime.utc_now),
      "word" => word,
      "lookupTime" => Float.to_string(Timex.Duration.to_milliseconds(duration)),
      "anagrams" => matches
    }
    {:reply, {:ok, result}, socket}
  end

  defp find_anagrams(word) do
    normalized_word = word
    |> String.trim
    |> String.downcase
    |> String.to_charlist
    |> Enum.sort

    Agent.get(:dictionary, fn dictionary -> Map.get(dictionary, normalized_word, []) end)
  end
end
