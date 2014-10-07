class Subscription < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :repo
  belongs_to :user
end
