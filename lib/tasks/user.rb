namespace :user do
  desc "Reset refreshing_repos flag for stuck users"
  task reset_refreshing_repos_for_stuck_users: :environment do
    stuck_users = User.where(
      "refreshing_repos = true AND updated_at < NOW() - interval '10 minutes'"
    )

    stuck_users.update_all(refreshing_repos: false)
  end
end
