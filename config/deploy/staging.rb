server ENV['STAGING_SERVER'], user: ENV['STAGING_USER'], roles: %w{web app db}
set :branch, "master"

set :deploy_to, ENV['STAGING_DEPLOY_PATH']

set :docker_copy_data, %w(config/secrets.yml config/database.yml)
set :docker_volumes, ["#{fetch(:deploy_to)}/shared/log:/var/www/app/log"]
set :docker_dockerfile, "docker/staging/Dockerfile"
