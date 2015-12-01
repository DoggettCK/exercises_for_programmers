use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :password_strength, PasswordStrength.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :password_strength, PasswordStrength.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "password_strength_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
