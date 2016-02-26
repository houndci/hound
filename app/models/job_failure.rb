class JobFailure < OpenStruct
  extend ActiveModel::Naming

  def self.all
    failures = Resque::Failure.all(0, Resque::Failure.count)
    [failures].flatten.map.with_index do |failure, index|
      JobFailure.new(failure.merge("index" => index))
    end
  end
end
