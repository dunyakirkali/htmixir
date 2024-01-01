defmodule Htmixir.Router do
  use Plug.Router

  @template_dir "priv/templates"

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:match)
  plug(:dispatch)

  get "/contact/1" do
    contact =
      File.read!("priv/stubs/contact")
      |> Base.decode64!()
      |> :erlang.binary_to_term()

    render(conn, "contact.html", contact: contact)
  end

  get "contact/1/edit" do
    contact =
      File.read!("priv/stubs/contact")
      |> Base.decode64!()
      |> :erlang.binary_to_term()

    render(conn, "contact_edit.html", contact: contact)
  end

  put "contact/1" do
    contact =
      %Htmixir.Contact{
        first_name: conn.body_params["firstName"],
        last_name: conn.body_params["lastName"],
        email: conn.body_params["email"]
      }

    b64term =
      contact
      |> :erlang.term_to_binary()
      |> Base.encode64()

    File.write!("priv/stubs/contact", b64term)

    render(conn, "contact.html", contact: contact)
  end

  defp render(%{status: status} = conn, template, assigns) do
    assigns |> IO.inspect()

    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns: assigns)

    send_resp(conn, status || 200, body)
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end
end
