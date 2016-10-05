class Subscription < ActiveRecord::Base
  acts_as_paranoid

  TIER1_ID = "tier1".freeze
  TIER2_ID = "tier2".freeze
  TIER3_ID = "tier3".freeze

  TIERS = {
    1..4 => TIER1_ID,
    5..10 => TIER2_ID,
    11..30 => TIER3_ID,
  }.freeze

  belongs_to :repo
  belongs_to :user
end
