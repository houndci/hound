#!/usr/bin/env rake
require "bundler/gem_tasks"
  require 'open-uri'

desc "Download the latest normalize.css"
task :update do
  url = "https://raw.github.com/necolas/normalize.css/master/normalize.css"
  outputfile = "vendor/assets/stylesheets/normalize-rails/normalize.css"

  open(outputfile, 'wb') do |file|
    file << open(url).read
  end

end
