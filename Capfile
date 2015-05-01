require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano3/nginx_unicorn"
require "capistrano/file-permissions"

Dir.glob("lib/capistrano/tasks/*.cap").each { |r| import r }
