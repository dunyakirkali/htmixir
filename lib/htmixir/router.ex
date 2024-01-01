defmodule Htmixir.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end
end
