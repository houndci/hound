class FileReview < ActiveRecord::Base
  belongs_to :build

  validates :build, presence: :true

  def completed?
    completed_at?
  end

  def running?
    !completed?
  end
end
