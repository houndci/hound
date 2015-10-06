module HamlLint
  # Checks for missing `alt` attributes on `img` tags.
  class Linter::AltText < Linter
    include LinterRegistry

    def visit_tag(node)
      if node.tag_name == 'img' && !node.has_hash_attribute?(:alt)
        record_lint(node, '`img` tags must include alt text')
      end
    end
  end
end
