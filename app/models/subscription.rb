class Subscription < ActiveRecord::Base
  acts_as_paranoid

  PLANS = {
    personal: 9,
    organization: 24,
    free: 0
  }

  belongs_to :repo
  belongs_to :user

  def self.org_price
    PLANS[:organization]
  end

  def self.personal_price
    PLANS[:personal]
  end
end
