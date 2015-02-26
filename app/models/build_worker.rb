class BuildWorker < ActiveRecord::Base
  belongs_to :build

  validates :build, presence: :true
end
