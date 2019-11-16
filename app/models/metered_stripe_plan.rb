class MeteredStripePlan < Plan
  PLANS = [
    { id: "basic", price: 0, title: "Open Source", range: (0..0) },
    { id: "tier1", price: 29, title: "Chihuahua", range: (0..50) },
    { id: "tier2", price: 49, title: "Terrier", range: (51..300) },
    { id: "tier3", price: 99, title: "Labrador", range: (301..1_000) },
    { id: "tier4", price: 199, title: "Husky", range: (1_001..3_000) },
    { id: "tier5", price: 299, title: "Great Dane", range: (3_001..10_000) },
  ].freeze
end
