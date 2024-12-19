defmodule HeadsUpWeb.PageController do
  use HeadsUpWeb, :controller

  def home(conn, _) do
    redirect(conn, to: ~p"/incidents")
  end
end
