require "administrate/base_dashboard"

class BulkCustomerDashboard < Administrate::BaseDashboard
  READ_ONLY_ATTRIBUTES = [
    :id,
    :created_at,
    :updated_at,
  ]

  ATTRIBUTE_TYPES = {
    id: Field::String,
    created_at: Field::String,
    updated_at: Field::String,
    org: Field::String,
    description: Field::String,
    interval: Field::String,
    repo_limit: Field::String,
    current_repos: Field::String,
    subscription_token: Field::String,
  }

  TABLE_ATTRIBUTES = [
    :org,
    :description,
    :repo_limit,
    :current_repos,
  ]

  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys
  FORM_ATTRIBUTES = ATTRIBUTE_TYPES.keys - READ_ONLY_ATTRIBUTES
end
