# frozen_string_literal: true

require "administrate/base_dashboard"

class OwnerDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    organization: Field::Boolean,
    whitelisted: Field::Boolean,
    config_enabled: Field::Boolean,
    config_repo: Field::String,
    active_private_repos_count: Field::Number,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :active_private_repos_count,
    :whitelisted,
    :config_enabled,
    :config_repo,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :whitelisted,
    :config_enabled,
    :config_repo,
  ]

  # Overwrite this method to customize how bulk customers are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(owner)
  #   "Owner ##{owner.id}"
  # end
end
