require "rails_helper"

feature "Error Pages" do
  scenario "user views error page" do
    visit "/404"

    expect(page.status_code).to eq 404
    expect(page).to have_content("The page you were looking for doesn't exist")
  end
end
