# frozen_string_literal: true

require "capybara/dsl"

class UserOnPage
  include Capybara::DSL

  def update(email_address)
    fill_in "email_address", with: email_address
    click_on "Update Email"
  end

  def updated?
    flash_element.has_text? "Email address updated!"
  end

  private

  def flash_element
    find("[data-role='flash']")
  end
end
