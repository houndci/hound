class BraceRule < Rule
  def violated?(text)
    braces = /{|}/
    space_around_braces = /\s\{(\s[^\s]|\n).*(\n\s+|[^\s]\s)\}/m
    used_for_interpolation = /#\{/

    if text =~ braces
      unless text =~ used_for_interpolation
        !(text =~ space_around_braces)
      end
    end
  end
end
