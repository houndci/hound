lock "3.3.5"

set :application, "hound"
set :repo_url, "git@github.com:JensDebergh/hound.git"
set :branch, "jd-deploy"
set :user, "typework"

set :linked_files, %w{.env}
set :linked_dirs, %w{bin log tmp public/assets public/sites public/system}

set :rbenv_type, :system
set :rbenv_ruby, "2.1.5"
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

set :nginx_server_name, "hound.typework.com"
set :nginx_use_spdy, false

set :nginx_ssl_certificate, ""
set :nginx_ssl_certificate_key, ""

set :nginx_enable_pagespeed, true
set :nginx_pagespeed_enabled_filters, "lazyload_images"

set :unicorn_workers, 2

set :file_permissions_roles, :all
set :file_permissions_paths, ["/usr/local/rbenv"]
set :file_permissions_users, ["typework"]
set :file_permissions_chmod_mode, "0770"

SSHKit.config.command_map[:rake]  = "bundle exec rake"
SSHKit.config.command_map[:rails] = "bundle exec rails"

namespace :deploy do
  after "updated", "set_permissions:chmod"
end
