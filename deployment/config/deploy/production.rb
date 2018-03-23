server ENV['PROD_SERVER'], user: ENV['PROD_USER'], roles: %w{web app db}
set :branch, ENV['REVISION'] || 'production'
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

# SHARED_PATH=... PROD_SERVER=... PROD_USER=... REVISION=... bundle exec cap production deploy
