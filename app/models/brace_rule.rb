class BraceRule < Rule
  def violated?(text)
    braces = /{|}/
    space_around_braces = /\s\{(\s[^\s]|\n).*(\n\s+|[^\s]\s)\}/m

    if text =~ braces
      !(text =~ space_around_braces)
    end
  end
end
