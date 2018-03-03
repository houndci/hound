# frozen_string_literal: true

namespace :webpack do
  desc "Build the asset bundle with Webpack"
  task :build do
    sh "yarn run build"
  end
end
