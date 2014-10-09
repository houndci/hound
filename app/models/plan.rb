class Plan
  PRICES = {
    exempt: 0,
    public: 0,
    private: 12
  }

  TYPES = {
    exempt: "exempt",
    public: "public",
    private: "private"
  }

  def initialize(repo)
    @repo = repo
  end

  def type
    if @repo.exempt?
      TYPES[:exempt]
    elsif @repo.private?
      TYPES[:private]
    else
      TYPES[:public]
    end
  end

  def price
    if @repo.exempt?
      PRICES[:exempt]
    elsif @repo.private?
      PRICES[:private]
    else
      PRICES[:public]
    end
  end
end
