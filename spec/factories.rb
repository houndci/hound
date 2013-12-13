FactoryGirl.define do
  factory :build do
    repo

    trait :failed_build do
      violations ['WhitespaceRule on line 34 of app/models/user.rb']
    end
  end

  factory :repo do
    sequence(:name) { |n| "Repo #{n}" }
    sequence(:full_github_name) { |n| "user/repo#{n}" }
    sequence(:github_id) { |n| n }
    active false

    factory :active_repo do
      active true
    end
  end

  factory :user do
    sequence(:github_username) { |n| "github#{n}" }
    sequence(:github_token) { |n| "token#{n}" }
  end

  factory :membership do
    user
    repo
  end
end
