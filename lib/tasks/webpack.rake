namespace :webpack do
  desc "Build the asset bundle with Webpack (production)"
  task :build do
    sh "npm run build:prod"
  end
end
