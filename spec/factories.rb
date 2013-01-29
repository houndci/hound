FactoryGirl.define do
  factory :repo do
    user
    sequence(:github_id) { |n| n }
    active false
  end

  factory :user do
    sequence(:github_username) { |n| "github#{n}" }
  end
end
