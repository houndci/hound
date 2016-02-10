server ENV['PROD_SERVER'], user: ENV['PROD_USER'], roles: %w{web app db}
set :branch, "production"

set :deploy_to, ENV['PROD_DEPLOY_PATH']

set :docker_copy_data, %w(config/secrets.yml config/database.yml)
set :docker_volumes, [
  "#{shared_path}/log:/var/www/app/log",
  "#{shared_path}/assets:/var/www/app/public/assets"
]
set :docker_dockerfile, "docker/production/Dockerfile"
