FactoryGirl.define do
  sequence(:github_id)
  sequence(:github_name) { |n| "github_name#{n}" }

  factory :build do
    repo

    trait :failed do
      after(:build) { |build| build.violations << build(:violation) }
    end
  end

  factory :file_review do
    build

    trait :completed do
      completed_at Time.zone.now
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
    github_id
    private false
    in_organization false
  end

  factory :user do
    github_username { generate(:github_name) }

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

  factory :owner do
    github_id
    name { generate(:github_name) }
  end
end
