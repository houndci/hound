set :production

server "hound.typework.com", user: "typework", roles: %w{web app db}
set :branch, ""
set :nginx_server_name, "hound.typework.com"

set :unicorn_workers, 2
