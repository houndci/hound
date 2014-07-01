require "spec_helper"

feature "Account" do
  scenario "viewing" do
    user = create(:user)
    org_repo1 = create(:repo, :in_private_org, users: [user])
    org_repo2 = create(:repo, :in_private_org, users: [user])
    personal_repo = create(:repo, users: [user], private: true)
    create(:subscription, repo: org_repo1, user: user)
    create(:subscription, repo: org_repo2, user: user)
    create(:subscription, repo: personal_repo, user: user)
    inactive_subscription = create(:subscription, :inactive, user: user)
    sign_in_as(user)

    visit account_path

    expect(page).to have_css(".account-breakdown", text: "$57.00")
    expect(page).to have_css(".repos-breakdown", text: org_repo1.name)
    expect(page).to have_css(".repos-breakdown", text: org_repo2.name)
    expect(page).to have_css(".repos-breakdown", text: personal_repo.name)
    expect(page).
      not_to have_css(".repos-breakdown", text: inactive_subscription.repo.name)
  end
end
