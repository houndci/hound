module HamlLint::Tree
  # Represents a node which produces output based on Ruby code.
  class ScriptNode < Node
    # Returns the source for the script following the `-` marker.
    #
    # @return [String]
    def script
      @value[:text]
    end
  end
end
