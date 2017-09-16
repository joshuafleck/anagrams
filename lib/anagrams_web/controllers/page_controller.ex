defmodule AnagramsWeb.PageController do
  use AnagramsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
