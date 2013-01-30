RSpec::Matchers.define :violate do |rule|
  match do |actual|
    rule.new.violated?(actual)
  end
end
