server ENV['STAGING_SERVER'], user: ENV['STAGING_USER'], roles: %w(app db web)
set :branch, ENV['REVISION'] || 'master'
set :application, 'hound-pr'
set :deploy_to, "/home/deploy/apps/#{fetch(:application)}"

set :default_env, lambda {
  {
    'SHARED_PATH' => ENV['SHARED_PATH'],
  }
}

set :capose_commands, -> {
  [
    "build",
    "run --rm web bundle exec rake assets:precompile",
    "run --rm web bundle exec rake db:migrate",
    "up -d"
  ]
}

# SHARED_PATH=... STAGING_SERVER=... STAGING_USER=... REVISION=... bundle exec cap staging deploy
