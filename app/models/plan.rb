class Plan
  PRICES = {
    bulk: 0,
    public: 0,
    private: 0
  }

  TYPES = {
    bulk: "bulk",
    public: "public",
    private: "private"
  }

  def initialize(repo)
    @repo = repo
  end

  def type
    if @repo.bulk?
      TYPES[:bulk]
    elsif @repo.private?
      TYPES[:private]
    else
      TYPES[:public]
    end
  end

  def price
    if @repo.bulk?
      PRICES[:bulk]
    elsif @repo.private?
      PRICES[:private]
    else
      PRICES[:public]
    end
  end
end
