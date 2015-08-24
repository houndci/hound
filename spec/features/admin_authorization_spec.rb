require "rails_helper"

feature "Admin authorization" do
  scenario "admin accesses dashboard" do
    stub_repos_requests(token)
    stub_admin_github_usernames("admin_user,other_admin_user")
    admin = create(:user, github_username: "admin_user")

    sign_in_as(admin, token)
    visit admin_bulk_customers_path

    expect(page).to have_admin_bulk_customers_header
  end

  scenario "non-admin cannot access dashboard" do
    stub_repos_requests(token)
    stub_admin_github_usernames("admin_user,other_admin_user")
    non_admin = create(:user, github_username: "not_admin_user")

    sign_in_as(non_admin, token)
    visit admin_bulk_customers_path

    expect(page).not_to have_admin_bulk_customers_header
  end

  def stub_admin_github_usernames(usernames)
    allow(ENV).to receive(:fetch).
      with("ADMIN_GITHUB_USERNAMES", "").
      and_return(usernames)
  end

  def have_admin_bulk_customers_header
    have_css("h1", text: "Bulk Customers")
  end

  def token
    "usergithubtoken"
  end
end
