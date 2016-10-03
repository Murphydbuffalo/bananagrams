# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bananagrams,
  ecto_repos: [Bananagrams.Repo]

# Configures the endpoint
config :bananagrams, Bananagrams.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ITLQQNzw7BvBLjd1gSV5gplZClv6EXtAEf4clZ/rJ2hpuXPm7K/xcO5oJ1KzU8rR",
  render_errors: [view: Bananagrams.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bananagrams.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
