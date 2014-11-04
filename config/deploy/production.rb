set :stage, :production

server "80.240.130.206", user: "typework", roles: %w{web app db}
set :branch, "master"
set :nginx_server_name, "hubert.com"

set :nginx_use_spdy, false
set :nginx_ssl_certificate, ""
set :nginx_ssl_certificate_key, ""

set :nginx_enable_pagespeed, true
set :nginx_pagespeed_enabled_filters, "lazyload_images"

set :unicorn_workers, 2
