require "administrate/base_dashboard"

class BulkCustomerDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    org: Field::String,
    description: Field::String,
    interval: Field::String,
    repo_limit: Field::Number,
    current_repos: Field::Number,
    subscription_token: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :org,
    :description,
    :repo_limit,
    :current_repos,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :org,
    :description,
    :interval,
    :repo_limit,
    :current_repos,
    :subscription_token,
  ]

  # Overwrite this method to customize how bulk customers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(bulk_customer)
  #   "BulkCustomer ##{bulk_customer.id}"
  # end
end
