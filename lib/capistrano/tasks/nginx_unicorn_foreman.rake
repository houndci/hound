namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export do
    on roles(:app) do
      execute "cd /var/www/#{fetch(:application)} && sudo bundle exec foreman export upstart /etc/init -a #{fetch(:application)} -u #{:user}"
    end
  end
  
  desc "Start the application services"
  task :start do
    on roles(:app) do
      sudo "start #{fetch(:application)}"
    end
  end
 
  desc "Stop the application services"
  task :stop do
    on roles(:app) do
      sudo "stop #{fetch(:application)}"
    end
  end
 
  desc "Restart the application services"
  task :restart do
    on roles(:app) do
      execute "sudo start #{fetch(:application)} || sudo restart my-ossum-app"
    end
  end
end
 
after "deploy:update", "foreman:export"
after "deploy:update", "foreman:restart"
