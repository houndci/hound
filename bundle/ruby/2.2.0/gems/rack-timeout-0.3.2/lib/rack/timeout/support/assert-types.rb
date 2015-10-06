require_relative "namespace"

module Rack::Timeout::AssertTypes
  extend self

  def assert_types! value_type_map
    value_type_map.each do |val, types|
      types = [types] unless types.is_a? Array
      next if types.any? { |type| val.is_a? type }
      raise TypeError, "#{val.inspect} is not a #{types.join(" | ")}"
    end
  end

end
