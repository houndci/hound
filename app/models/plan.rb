class Plan
  PRICES = {
    public: 0,
    private: 12
  }

  TYPES = {
    public: "public",
    private: "private"
  }

  def initialize(repo)
    @repo = repo
  end

  def type
    if @repo.private?
      TYPES[:private]
    else
      TYPES[:public]
    end
  end

  def price
    if @repo.private?
      PRICES[:private]
    else
      PRICES[:public]
    end
  end
end
