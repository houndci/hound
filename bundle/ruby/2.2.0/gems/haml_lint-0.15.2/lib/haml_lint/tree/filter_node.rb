module HamlLint::Tree
  # Represents a filter node which contains arbitrary code.
  class FilterNode < Node
    # The type of code contained in this filter.
    def filter_type
      @value[:name]
    end
  end
end
