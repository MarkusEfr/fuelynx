defmodule FuelynxWeb.PageController do
  use FuelynxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
