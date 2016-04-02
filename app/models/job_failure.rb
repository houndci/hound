class JobFailure < OpenStruct
  FIRST_INDEX = 0
  extend ActiveModel::Naming

  def self.all
    failures = Resque::Failure.all(FIRST_INDEX, Resque::Failure.count)
    [failures].flatten.map.with_index do |failure, index|
      JobFailure.new(failure.merge("index" => index))
    end
  end

  def self.remove(indexes)
    indexes.reverse.each { |index| Resque::Failure.remove(index) }
  end
end
