require "rails_helper"

feature "Admin authorization" do
  scenario "admin accesses dashboard" do
    stub_admin_usernames(["admin_user", "other_admin_user"])
    admin = create(:user, username: "admin_user")

    sign_in_as(admin, token)
    visit admin_blacklisted_pull_requests_path
    click_link "Bulk Customers"

    expect(page).to have_admin_bulk_customers_header
  end

  scenario "non-admin cannot access dashboard" do
    non_admin = create(:user, username: "not_admin_user")

    sign_in_as(non_admin, token)
    visit admin_bulk_customers_path

    expect(page).not_to have_admin_bulk_customers_header
  end

  def stub_admin_usernames(usernames)
    stub_const("Hound::ADMIN_GITHUB_USERNAMES", usernames)
  end

  def have_admin_bulk_customers_header
    have_css("h1", text: "Bulk Customers")
  end

  def token
    "usergithubtoken"
  end
end
