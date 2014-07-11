class Subscription < ActiveRecord::Base
  acts_as_paranoid

  PLANS = {
    personal: 9,
    organization: 24,
    free: 0
  }

  belongs_to :repo
  belongs_to :user
end
