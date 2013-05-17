FactoryGirl.define do
  factory :repo do
    user
    sequence(:name) { |n| "Repo #{n}" }
    sequence(:full_github_name) { |n| "user/repo#{n}" }
    sequence(:github_id) { |n| n }
    active false
  end

  factory :user do
    sequence(:github_username) { |n| "github#{n}" }
    sequence(:github_token) { |n| "token#{n}" }
  end
end
