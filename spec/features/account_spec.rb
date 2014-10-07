require "spec_helper"

feature "Account" do
  scenario "user with multiple subscriptions views account page" do
    user = create(:user)
    private_repo = create(:repo, users: [user])
    create(:subscription, repo: private_repo, user: user, price: 12)
    individual_repo = create(:repo, users: [user])
    create(:subscription, repo: individual_repo, user: user, price: 9)
    organization_repo = create(:repo, users: [user])
    create(:subscription, repo: organization_repo, user: user, price: 24)
    public_repo = create(:repo, users: [user])

    sign_in_as(user)

    visit account_path

    expect(page).to have_css(".account-breakdown", text: "$45.00")
    expect(page).to have_css(".repos-breakdown", text: private_repo.name)
    expect(page).to have_css(".repos-breakdown", text: individual_repo.name)
    expect(page).to have_css(".repos-breakdown", text: organization_repo.name)
    expect(page).not_to have_css(".repos-breakdown", text: public_repo.name)
  end
end
