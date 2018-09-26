namespace :plan do
  desc "Update marketplace plans for all owners"
  task update_all: :environment do
    UpdateGitHubPlans.call
  end
end
