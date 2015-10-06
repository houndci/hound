module HamlLint::Tree
  # Represents a HAML comment node.
  class HamlCommentNode < Node
    # Returns the full text content of this comment, including newlines if a
    # single comment spans multiple lines.
    #
    # @return [String]
    def text
      content = source_code
      indent = content[/^ */]

      content.gsub(/^#{indent}/, '')
             .gsub(/^-#/, '')
             .gsub(/^  /, '')
             .rstrip
    end
  end
end
