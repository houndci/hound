Split.configure do |config|
  config.experiments = {
    "auth_button" => {
      alternatives: ["original", "aggressive"]
    }
  }
end
