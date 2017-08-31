require "rails_helper"

feature "Plans" do
  scenario "shows all available plans", :js do
    user = create(:user)
    repo = create(:repo)
    sign_in_as(user, "letmein")

    visit plans_path(repo_id: repo.id)

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
    stub_repository_invitations(repo.name)
    stub_customer_find_request
    stub_subscription_create_request(plan: "tier1", repo_ids: repo.id)
    stub_subscription_update_request(plan: "tier2", repo_ids: repo.id)
    visit plans_path(repo_id: repo.id)

    click_on "Upgrade"

    wait_until_path_is(repos_path, "Timeout waiting for Upgrade to redirect")

    expect(page).to have_text "Private Repos 5 / 10"
  end

  def wait_until_path_is(path, message)
    Timeout.timeout(10) do
      break if current_path == path
      sleep 1
    end
  rescue Timeout::Error
    raise message
  end
end
