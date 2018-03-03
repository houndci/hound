# frozen_string_literal: true

module Hound
  CHANGED_FILES_THRESHOLD ||= ENV.fetch("CHANGED_FILES_THRESHOLD").to_i
  HTTPS_ENABLED ||= ENV.fetch("ENABLE_HTTPS") == "yes"
  GITHUB_CLIENT_ID ||= ENV.fetch("GITHUB_CLIENT_ID")
  GITHUB_CLIENT_SECRET ||= ENV.fetch("GITHUB_CLIENT_SECRET")
  HOST ||= ENV.fetch("HOST")
  GITHUB_TOKEN ||= ENV.fetch("HOUND_GITHUB_TOKEN")
  GITHUB_USERNAME ||= ENV.fetch("HOUND_GITHUB_USERNAME")
  INTERCOM_API_SECRET ||= ENV.fetch("INTERCOM_API_SECRET")
  MAX_COMMENTS ||= ENV.fetch("MAX_COMMENTS").to_i
  SEGMENT_KEY ||= ENV.fetch("SEGMENT_KEY")
  STRIPE_PUBLISHABLE_KEY ||= ENV.fetch("STRIPE_PUBLISHABLE_KEY")
  ADMIN_GITHUB_USERNAMES ||= ENV.fetch("ADMIN_GITHUB_USERNAMES", "").split(",")
end
