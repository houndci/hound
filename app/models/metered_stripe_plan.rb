class MeteredStripePlan < Plan
  PLANS = [
    {
      id: nil,
      price: 0,
      title: "Open Source",
      range: (0..0),
    },
    {
      id: "plan_FXpsAlar939qfx",
      price: 29,
      title: "Chihuahua",
      range: (0..50),
    },
    {
      id: "plan_FXpsHlYOH8tAfo",
      price: 49,
      title: "Terrier",
      range: (51..300),
    },
    {
      id: "plan_FXptlXmCZwt7Rf",
      price: 99,
      title: "Labrador",
      range: (301..1_000),
    },
    {
      id: "plan_FXptCDypXrtK0c",
      price: 199,
      title: "Husky",
      range: (1_001..3_000),
    },
    {
      id: "plan_FXpu6Y3Dhrllj6",
      price: 299,
      title: "Great Dane",
      range: (3_001..10_000),
    },
  ].freeze
end
