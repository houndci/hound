class Rule
  def initialize(text)
    @text = text
  end

  def violated?
    !satisfied?
  end

  private

  def does_not_have?(pattern)
    @text !~ pattern
  end
end
