module HamlLint::Tree
  # Represents a HAML silent script node (`- some_expression`) which executes
  # code without producing output.
  class SilentScriptNode < Node
    # Returns the source for the script following the `-` marker.
    #
    # @return [String]
    def script
      @value[:text]
    end
  end
end
