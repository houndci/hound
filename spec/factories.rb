FactoryGirl.define do
  factory :build do
    repo

    trait :failed do
      after(:build) { |build| build.violations << build(:violation) }
    end
  end

  factory :repo do
    trait(:active) { active true }
    trait(:inactive) { active false }
    trait(:in_private_org) do
      active true
      in_organization true
      private true
    end

    sequence(:full_github_name) { |n| "user/repo#{n}" }
    sequence(:github_id) { |n| n }
    private false
    in_organization false
  end

  factory :user do
    sequence(:github_username) { |n| "github#{n}" }

    ignore do
      repos []
    end
  end

  factory :membership do
    user
    repo
  end

  factory :subscription do
    trait(:inactive) { deleted_at { 1.day.ago } }

    sequence(:stripe_subscription_id) { |n| "stripesubscription#{n}" }

    price { repo.plan_price }
    repo
    user
  end

  factory :violation do
    build

    filename "the_thing.rb"
    patch_position 1
    line_number 42
    messages ["Trailing whitespace detected."]
  end
end
