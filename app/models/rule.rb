class Rule
  def initialize(text)
    @text = text
  end

  def violated?
    !satisfied?
  end
end
