defmodule Mp3Parser.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Mp3Parser.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import Mp3Parser.Router.Helpers

      # The default endpoint for testing
      @endpoint Mp3Parser.Endpoint
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Mp3Parser.Repo, [])
    end

    :ok
  end
end
