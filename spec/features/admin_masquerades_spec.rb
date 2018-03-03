# frozen_string_literal: true

require "rails_helper"

feature "Admin masquerades as user" do
  scenario "admin sees user repos and can stop masquerading" do
    repo = create(:repo)
    admin = create(:user, username: "admin", token: "admin")
    user = create(:user, repos: [repo], username: "admin", token: "user")
    stub_const("Hound::ADMIN_GITHUB_USERNAMES", ["admin"])

    sign_in_as(admin, "admin")
    visit admin_masquerade_path(user.username)

    expect(current_path).to eq(repos_path)
    within ".app-nav" do
      expect(page).to have_text(user.username)
    end

    click_on "Stop Masquerading"

    within ".app-nav" do
      expect(page).to have_text(admin.username)
    end
  end
end
