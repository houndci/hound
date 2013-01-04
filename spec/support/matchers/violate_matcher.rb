RSpec::Matchers.define :violate do |rule|
  match do |actual|
    rule.new(actual).violated?
  end
end
