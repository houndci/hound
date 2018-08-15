class StripePlan < Plan
  PLANS = [
    { id: "basic", price: 0, range: 0..0, title: "Hound" },
    { id: "tier1", price: 49, range: 1..4, title: "Chihuahua" },
    { id: "tier2", price: 99, range: 5..10, title: "Labrador" },
    { id: "tier3", price: 249, range: 11..30, title: "Great Dane" },
  ].freeze
end
