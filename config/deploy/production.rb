server "80.240.130.206", user: "typework", roles: %w{web app db}

set :ssh_options, {
  forward_agent: true,
  port: 12013
}
