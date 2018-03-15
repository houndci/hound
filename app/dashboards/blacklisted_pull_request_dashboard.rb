# frozen_string_literal: true

require "administrate/base_dashboard"

class BlacklistedPullRequestDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    full_repo_name: Field::String,
    pull_request_number: Field::Number,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :full_repo_name,
    :pull_request_number,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :full_repo_name,
    :pull_request_number,
  ].freeze

  FORM_ATTRIBUTES = [
    :full_repo_name,
    :pull_request_number,
  ].freeze
end
