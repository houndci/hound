class Ownership < ApplicationRecord
  belongs_to :owner
  belongs_to :user
end
