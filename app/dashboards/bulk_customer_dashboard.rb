require "administrate/base_dashboard"

class BulkCustomerDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    org: Field::String,
    description: Field::String,
    interval: Field::String,
    repo_limit: Field::Number,
    current_repos: Field::Number,
    subscription_token: Field::String,
  }

  COLLECTION_ATTRIBUTES = [
    :org,
    :description,
    :repo_limit,
    :current_repos,
  ]

  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  FORM_ATTRIBUTES = [
    :org,
    :description,
    :interval,
    :repo_limit,
    :current_repos,
    :subscription_token,
  ]
end
