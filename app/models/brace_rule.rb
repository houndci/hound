class BraceRule < Rule
  def violated?
    space_around_braces = /\s\{(\s[^\s]|\n).*(\n\s+|[^\s]\s)\}/m

    does_not_have?(space_around_braces)
  end

  def does_not_have?(pattern)
    !has?(pattern)
  end
end
