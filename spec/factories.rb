FactoryGirl.define do
  factory :repo do
    user
    sequence(:github_id) { |n| n }
    full_github_name 'user/repo'
    active false
  end

  factory :user do
    sequence(:github_username) { |n| "github#{n}" }
  end
end
