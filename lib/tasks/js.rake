namespace :js do
  task spec: "webpack:build" do
    sh "yarn run test"
  end
end
