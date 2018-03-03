# frozen_string_literal: true

namespace :js do
  task :spec do
    sh "yarn run test"
  end
end
