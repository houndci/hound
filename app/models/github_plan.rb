class GitHubPlan < Plan
  PLANS = [
    {
      id: 1061,
      price: 0,
      range: 0..0,
      title: "Hound",
      slug: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYx",
    },
    {
      id: 1062,
      price: 49,
      range: 1..4,
      title: "Chihuahua",
      slug: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYy",
    },
    {
      id: 1063,
      price: 149,
      range: 5..20,
      title: "Octodog",
      slug: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYz",
    },
  ].freeze

  attr_reader :slug

  def initialize(id:, range:, price:, title:, slug:)
    @id = id
    @range = range
    @price = price
    @title = title
    @slug = slug
  end
end
