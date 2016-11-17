require "rails_helper"

feature "Listing Pricings" do
  scenario "shows all available plans", :js do
    user = create(:user)
    repo = create(:repo)
    sign_in_as(user, "letmein")

    visit pricings_path(repo_id: repo.id)

    plans = page.all(".plan")
    expect(plans.count).to eq 4

    within(plans[0]) do
      expect(page).to have_content("CURRENT PLAN")

      expect(find(".plan-title").text).to eq "Hound"
      expect(find(".plan-allowance").text).to eq "Unlimited"
      expect(find(".plan-price").text).to eq "$0 month"
    end

    within(plans[1]) do
      expect(page).to have_content("NEW PLAN")

      expect(find(".plan-title").text).to eq "Chihuahua"
      expect(find(".plan-allowance").text).to eq "Up to 4 Repos"
      expect(find(".plan-price").text).to eq "$49 month"
    end

    within(plans[2]) do
      expect(find(".plan-title").text).to eq "Labrador"
      expect(find(".plan-allowance").text).to eq "Up to 10 Repos"
      expect(find(".plan-price").text).to eq "$99 month"
    end

    within(plans[3]) do
      expect(find(".plan-title").text).to eq "Great Dane"
      expect(find(".plan-allowance").text).to eq "Up to 30 Repos"
      expect(find(".plan-price").text).to eq "$249 month"
    end
  end

  scenario "user upgrades their subscription", :js do
    hook_url = "http://#{ENV['HOST']}/builds"
    user = create(:user, stripe_customer_id: stripe_customer_id)
    token = "letmein"
    sign_in_as(user, token)

    4.times do
      repo = create(:repo, active: true)
      create(:membership, admin: true, repo: repo, user: user)
      create(:subscription, repo: repo, user: user)
    end

    repo = create(:repo, private: true)
    create(:membership, admin: true, repo: repo, user: user)
    username = ENV.fetch("HOUND_GITHUB_USERNAME")
    stub_add_collaborator_request(username, repo.name, token)
    stub_customer_find_request
    stub_hook_creation_request(repo.name, hook_url, token)
    stub_subscription_create_request(plan: "tier1", repo_ids: repo.id)
    stub_subscription_update_request(plan: "tier2", repo_ids: repo.id)
    visit pricings_path(repo_id: repo.id)

    click_on "Upgrade"
    wait_for_ajax

    expect(current_path).to eq repos_path
    expect(page).to have_content "Private Repos 5/10"
  end
end
