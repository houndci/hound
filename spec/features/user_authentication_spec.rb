require 'spec_helper'

feature 'User authentication' do
  scenario "when user already exists, signs in" do
    user = create(:user)
    stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)

    sign_in_as(user)

    expect(page).to have_content user.github_username
    expect(analytics).to have_tracked("Signed In").for_user(user)
  end

  context "signs up" do
    scenario "when user doesn't exist" do
      github_username = "croaky"
      user = build(:user, github_username: github_username)
      stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)

      sign_in_as(user)

      user = User.where(github_username: github_username).first
      expect(page).to have_content(github_username)
      expect(analytics).to have_tracked("Signed Up").for_user(user)
    end

    scenario "with campaign params" do
      github_username = "croaky"
      user = build(:user, github_username: github_username)
      stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)
      campaign_params = {
        utm_campaign: "adwords-ruby",
        utm_medium: "paidsearch",
        utm_source: "adwords",
      }
      campaign_context = {
        name: "adwords-ruby",
        medium: "paidsearch",
        source: "adwords",
      }

      sign_in_as(user, campaign_params)

      user = User.where(github_username: github_username).first
      expect(page).to have_content(github_username)
      expect(analytics).to have_tracked("Signed Up").
        for_user(user).
        with(context: { campaign: campaign_context })
    end
  end

  scenario 'user signs out' do
    user = create(:user)
    stub_repo_requests(AuthenticationHelper::GITHUB_TOKEN)
    sign_in_as(user)

    find('a[href="/sign_out"]').click

    expect(page).not_to have_content user.github_username
  end
end
