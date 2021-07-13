require "rails_helper"

RSpec.feature "Plans" do
  scenario "shows all available plans", :js do
    user = create(:user)
    repo = create(:repo)
    sign_in_as(user, "letmein")

    visit plans_path(repo_id: repo.id)

    expect(page).to have_css(".plan", count: 7)

    within ".plan:nth-of-type(1)" do
      expect(page).to have_content("CURRENT PLAN")
      expect(find(".plan-title").text).to eq "Open Source"
      expect(find(".plan-allowance").text).to eq "Unlimited"
      expect(find(".plan-price").text).to eq "$0 month"
    end

    within ".plan:nth-of-type(2)" do
      expect(page).to have_content("NEW PLAN")

      expect(find(".plan-title").text).to eq "Chihuahua"
      expect(find(".plan-allowance").text).to eq "Up to 50 Reviews"
      expect(find(".plan-price").text).to eq "$29 month"
    end

    within ".plan:nth-of-type(3)" do
      expect(find(".plan-title").text).to eq "Terrier"
      expect(find(".plan-allowance").text).to eq "Up to 300 Reviews"
      expect(find(".plan-price").text).to eq "$49 month"
    end

    within ".plan:nth-of-type(4)" do
      expect(find(".plan-title").text).to eq "Labrador"
      expect(find(".plan-allowance").text).to eq "Up to 1,000 Reviews"
      expect(find(".plan-price").text).to eq "$99 month"
    end

    within ".plan:nth-of-type(5)" do
      expect(find(".plan-title").text).to eq "Husky"
      expect(find(".plan-allowance").text).to eq "Up to 3,000 Reviews"
      expect(find(".plan-price").text).to eq "$199 month"
    end

    within ".plan:nth-of-type(6)" do
      expect(find(".plan-title").text).to eq "Great Dane"
      expect(find(".plan-allowance").text).to eq "Up to 10,000 Reviews"
      expect(find(".plan-price").text).to eq "$299 month"
    end
  end

  scenario "user upgrades their subscription", :js do
    user = create(:user, :stripe)
    repo = create(:repo, :private)
    create(:membership, :admin, repo: repo, user: user)
    stub_repository_invitations(repo.name)
    stub_customer_find_request
    stub_subscription_create_request(
      plan: MeteredStripePlan::PLANS.second.fetch(:id),
      repo_ids: repo.id,
    )
    stub_subscription_update_request(
      repo_ids: repo.id,
    )

    sign_in_as(user)
    visit plans_path(repo_id: repo.id)
    click_on "Upgrade"
    wait_until_path_is(repos_path, "Timeout waiting for Upgrade to redirect")

    expect(page).to have_text "Recent Reviews"
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
