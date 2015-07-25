FactoryGirl.define do
  sequence(:github_id)
  sequence(:github_name) { |n| "github_name#{n}" }

  factory :build do
    commit_sha "somesha"
    repo
  end

  factory :file_review do
    trait :completed do
      completed_at Time.zone.now
    end

    build

    filename "the_thing.rb"
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
    file_review

    patch_position 1
    line_number 42
    messages ["Trailing whitespace detected."]
  end

  factory :owner do
    github_id
    name { generate(:github_name) }
  end

  factory :bulk_customer do
    org "bulk_org"
    interval "monthly"
    repo_limit 5
  end
end
