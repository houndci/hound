set :application, "hubert"

set :log_level, :info

set :scm, :git
set :repo_url,  "git@github.com:JensDebergh/hound.git"
set :deploy_to, "/var/www/hubert"
set :user, "typework"
set :keep_releases, 5

set :ssh_options, {
  forward_agent: true,
  port: 12013
}

set :rbenv_type, :system
set :rbenv_ruby, '2.1.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

SSHKit.config.command_map[:rake]  = "bundle exec rake"
SSHKit.config.command_map[:rails] = "bundle exec rails"

set :linked_files, %w{.env}
set :linked_dirs, %w{bin log tmp public/assets public/sites public/system}

set :file_permissions_roles, :all
set :file_permissions_paths, ["/usr/local/rbenv"]
set :file_permissions_users, ["typework"]
set :file_permissions_chmod_mode, "0770"

after "deploy:updated", "deploy:set_permissions:chmod"
