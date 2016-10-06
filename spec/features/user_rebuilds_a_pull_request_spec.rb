require "rails_helper"

feature "User rebuilds a pull request" do
  scenario "from the builds page" do
    user = create(:user, token_scopes: "public_repo,user:email")
    repo = create(:membership, user: user).repo
    build = create(:build, repo: repo)
    allow(SmallBuildJob).to receive(:perform_later)

    sign_in_as(user)
    visit builds_path
    within "#build_#{build.id}" do
      click_on I18n.t("builds.index.new")
    end

    expect(page).to have_text I18n.t("rebuilds.create.success")
  end
end
