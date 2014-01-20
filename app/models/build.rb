class Build < ActiveRecord::Base
  belongs_to :repo

  validates :repo, presence: true

  serialize :violations, Array

  def status
    if violations.any?
      'failed'   
    else
      'passed'
    end
  end
end
