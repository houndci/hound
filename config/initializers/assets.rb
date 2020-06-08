# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Precompile additional assets.
Rails.application.config.assets.precompile += %w( repos/*.js )

Rails.application.config.assets.paths << Rails.root.join("node_modules")
