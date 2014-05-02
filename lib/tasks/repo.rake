namespace :repo do
  desc 'Find 3,000 repos without privacy or organization information and update with info from GitHub'
  task backfill_privacy_and_organization: :environment do
    puts 'Finding repos ...'
    where_condition = <<-SQL
(private IS NULL OR in_organization IS NULL) AND updated_at IS NULL
    SQL
    repo_ids = Repo.where(where_condition).limit(3_000).pluck(:id)
    puts 'Scheduling RepoInformationJob jobs for repos ...'
    repo_ids.each do |repo_id|
      JobQueue.push(RepoInformationJob, repo_id, ENV['HOUND_GITHUB_TOKEN'])
    end
    puts 'Done scheduling jobs.
  end
end
