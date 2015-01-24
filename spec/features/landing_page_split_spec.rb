require "spec_helper"

feature "Landing page split testing" do
  scenario "user sees original landing page" do
    visit landing_page(:original)

    expect(page).to have_content(original_landing_page_content)
  end

  scenario "user sees an alternate landing page" do
    visit landing_page(:benefits)

    expect(page).to have_content(alternate_landing_page_content)
  end

  def landing_page(alternative)
    "/?landing_page=#{alternative}"
  end

  def original_landing_page_content
    "Review your JavaScript, CoffeeScript, and Ruby code for style guide violations with a trusty hound."
  end

  def alternate_landing_page_content
    "Keep your code clean with automated style checking"
  end
end
