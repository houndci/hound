# config valid only for current version of Capistrano
lock '3.4.1'

set :repo_url, 'git@github.com:netguru/hound.git'

set :docker_additional_options, -> { "--env-file #{shared_path}/.env" }
set :docker_apparmor_profile, "docker-ptrace"
set :docker_links, %w(redis_ambassador:redis postgres_ambassador:postgres)
