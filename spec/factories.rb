# frozen_string_literal: true

FactoryGirl.define do
  sequence(:github_id)
  sequence(:github_name) { |n| "github_name#{n}" }

  factory :blacklisted_pull_request do
    sequence(:full_repo_name) { |n| "user/repo#{n}" }
    sequence(:pull_request_number)
  end

  factory :build do
    sequence(:pull_request_number)
    commit_sha "somesha"
    repo
  end

  factory :file_review do
    trait :completed do
      completed_at Time.zone.now
    end

    build

    filename "the_thing.rb"
    linter_name "ruby"
  end

  factory :plan do
    id "tier1"
    price 49
    range 1..4
    title "Chihuahua"

    trait :plan2 do
      id "tier2"
      price 99
      range 5..10
      title "Labrador"
    end

    initialize_with { new(id: id, price: price, range: range, title: title) }
  end

  factory :repo do
    trait(:active) { active true }
    trait(:inactive) { active false }
    trait(:in_private_org) do
      active true
      in_organization true
      private true
    end
    trait(:private) { private true }

    sequence(:name) { |n| "user/repo#{n}" }
    github_id
    owner

    private false
    in_organization false
  end

  factory :user do
    username { generate(:github_name) }

    trait(:with_github_scopes) { token_scopes "public_repo,user:email" }
    trait(:stripe) { stripe_customer_id "cus_2e3fqARc1uHtCv" }
  end

  factory :membership do
    trait(:admin) { admin true }

    user
    repo
  end

  factory :subscription do
    trait(:inactive) { deleted_at { 1.day.ago } }

    sequence(:stripe_subscription_id) { |n| "stripesubscription#{n}" }

    association :repo, :active, :private
    price Plan::PLANS[1][:price]
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
end
