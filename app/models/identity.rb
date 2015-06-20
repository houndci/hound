class Identity < ActiveRecord::Base
  belongs_to :user

  validates :username, presence: true
  validates :provider,
            presence: true,
            inclusion: { in: %w(github bitbucket) }
end
