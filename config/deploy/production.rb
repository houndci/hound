set :stage, :production

server "188.226.154.160", user: "typework", roles: %w{web app db}
set :branch, "jd-add-deployment-scripts"

set :nginx_server_name, "hound"
set :nginx_use_spdy, false
set :nginx_enable_pagespeed, false

set :unicorn_workers, 2
