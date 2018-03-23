# config valid only for current version of Capistrano
lock '3.8.1'

set :application, 'hound'
set :repo_url, 'git@github.com:netguru/hound.git'
set :format_options, truncate: false
