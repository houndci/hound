require "spec_helper"

feature "Account" do
  scenario "user with multiple subscriptions views account page" do
    user = create(:user)
    individual_repo = create(:repo, users: [user])
    create(:subscription, repo: individual_repo, user: user, price: 9)
    private_repo = create(:repo, users: [user])
    create(:subscription, repo: private_repo, user: user, price: 12)
    organization_repo = create(:repo, users: [user])
    create(:subscription, repo: organization_repo, user: user, price: 24)
    public_repo = create(:repo, users: [user])

    sign_in_as(user)

    visit account_path

    expect(page).to have_text("$45")
    expect(page).to have_text("Private Personal Repos")
    expect(page).to have_text("Private Repos")
    expect(page).to have_text("Private Org Repos")
    expect(page).to have_text(private_repo.name)
    expect(page).to have_text(individual_repo.name)
    expect(page).to have_text(organization_repo.name)
    expect(page).not_to have_text(public_repo.name)
  end
end
