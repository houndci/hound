namespace :user do
  desc 'Backfill User Names'
  task backfill_names: :environment do
    puts 'Finding users ...'
    User.all.each do |user|
      JobQueue.push(UserNameJob, user.id)
    end
    puts 'Done scheduling jobs.'
  end
end
