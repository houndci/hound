require "spec_helper"

feature "Public Pages" do
  context "When a user is not logged in" do
    scenario "allows access to the FAQ page" do
      visit "/faq"

      expect(page).to have_content("Frequently Asked Questions")
    end
  end
end
