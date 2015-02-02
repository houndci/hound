require "spec_helper"

feature "Public Pages" do
  context "When a user is not signed in" do
    scenario "displays the FAQ page" do
      visit "/faq"

      expect(page).to have_content("Frequently Asked Questions")
      expect(page).to have_content("Sign In with GitHub")
    end

    scenario "displays the configuration page" do
      visit "/configuration"

      expect(page).to have_content("Configuration")
      expect(page).to have_content("Sign In with GitHub")
    end

    scenario "displays the configuration page with params and missing ?" do
      visit "/configuration&utm_source=Intercom"

      expect(page).to have_content("Configuration")
      expect(page).to have_content("Sign In with GitHub")
    end
  end
end
