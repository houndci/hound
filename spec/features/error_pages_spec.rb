require "rails_helper"

feature "Error Pages" do
  scenario "user views error page" do
    visit "/404"

    expect(page.status_code).to eq 404
    expect(page).to have_content("Oh no, this page doesn't exist")
  end
end
