source 'https://rubygems.org'

# Specify your gem's dependencies in rails_serve_static_assets.gemspec
gemspec :path => File.expand_path("../.", __FILE__)

group :development, :test do
  gem "sqlite3", :platform => [:ruby, :mswin, :mingw]
  gem "activerecord-jdbcsqlite3-adapter", '~> 1.3.13', :platform => :jruby
end

gem 'launchy'
