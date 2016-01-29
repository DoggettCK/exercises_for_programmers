ExUnit.start

Mix.Task.run "ecto.create", ~w(-r UrlShortener.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r UrlShortener.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(UrlShortener.Repo)

