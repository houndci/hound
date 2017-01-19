namespace :js do
  task spec: "webpack:build" do
    sh "npm run test"
  end
end
