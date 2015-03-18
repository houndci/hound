require "rails_helper"

feature "Account" do
  scenario "user without Stripe Customer ID" do
    user = create(:user, stripe_customer_id: nil)

    sign_in_as(user)
    visit account_path

    expect(page).not_to have_text("Update Credit Card")
  end

  scenario "user with Stripe Customer ID" do
    user = create(:user, stripe_customer_id: "123")

    sign_in_as(user)
    visit account_path

    expect(page).to have_text("Update Credit Card")
  end

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

  scenario "user sees paid repo usage" do
    user = create(:user)
    paid_repo = create(:repo, users: [user])
    paid_repo.builds << create(:build, :failed)
    paid_repo.builds << create(:build, :failed)
    paid_repo.builds << create(:build)
    create(:subscription, repo: paid_repo, user: user)

    sign_in_as(user)

    visit account_path

    expect(find('td.reviews-given')).to have_text("3");
    expect(find('td.violations-caught')).to have_text("2");
  end
end
