namespace :webpack do
  desc "Build the asset bundle with Webpack"
  task :build do
    sh "npm run build"
  end
end
