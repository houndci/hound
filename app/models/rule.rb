class Rule
  def initialize(text)
    @text = text
  end

  def violated?
    raise 'Must implement #violated? method'
  end

  private

  def has?(pattern)
    @text[pattern] != nil
  end
end
