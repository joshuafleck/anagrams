defmodule AnagramsWeb.PageController do
  use AnagramsWeb, :controller

  def index(conn, _params) do
    Agent.start(fn -> %{} end, name: :dictionary)
    Agent.update(:dictionary, fn _ -> %{} end)
    render conn, "index.html", dictionary: "No dictionary loaded"
  end

  def dictionary_upload(conn, %{"dictionary" => %{"upload" => upload}}) do
    {duration, dictionary} = Timex.Duration.measure(fn ->
      build_dictionary(upload.path)
    end)
    Agent.update(:dictionary, fn _ -> dictionary end)
    render conn, "index.html", dictionary: "#{upload.filename} loaded in #{Timex.Duration.to_milliseconds(duration)}ms"
  end

  defp build_dictionary(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.downcase/1)
    |> Stream.uniq()
    |> Enum.group_by(fn word ->
      Enum.sort(String.to_charlist(word))
    end)
  end
end
