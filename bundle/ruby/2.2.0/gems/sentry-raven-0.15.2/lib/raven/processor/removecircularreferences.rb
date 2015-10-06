module Raven
  class Processor::RemoveCircularReferences < Processor

    def process(v, visited = [])
      return "(...)" if visited.include?(v.__id__)
      visited += [v.__id__]
      if v.is_a?(Hash)
        v.reduce({}) { |memo, (k, v_)| memo[k] = process(v_, visited); memo }
      elsif v.is_a?(Array)
        v.map { |v_| process(v_, visited) }
      else
        v
      end
    end

  end
end
