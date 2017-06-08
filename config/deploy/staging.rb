server ENV['STAGING_SERVER'], user: ENV['STAGING_USER'], roles: %w{web app db}
set :branch, "master"
set :application, "hound-pr"

set :deploy_to, ENV['STAGING_DEPLOY_PATH']

set :docker_copy_data, %w(config/secrets.yml config/database.yml)
set :docker_volumes, [
  "#{shared_path}/log:/var/www/app/log",
  "#{shared_path}/assets:/var/www/app/public/assets"
]
set :docker_dockerfile, "docker/staging/Dockerfile"

Rake::Task["docker:deploy:default:tag"].clear_actions

namespace :docker do
  namespace :deploy do
    namespace :default do
      task :tag do
        on roles(fetch(:docker_role)) do
          execute :docker, "tag #{fetch(:docker_image_full)} #{fetch(:docker_image)}:latest"
        end
      end
    end
  end
end
