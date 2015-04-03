require "spec_helper"

feature "Authentication split testing" do
  scenario "user sees original authentication button" do
    visit auth_button(:original)

    expect(page).to have_content(original_auth_button_content)
  end

  scenario "user sees an alternate authentication button" do
    visit auth_button(:aggressive)

    expect(page).to have_content(alternate_auth_button_content)
  end

  def auth_button(alternative)
    "/?auth_button=#{alternative}"
  end

  def original_auth_button_content
    I18n.t("authenticate")
  end

  def alternate_auth_button_content
    I18n.t("aggressive_authenticate")
  end
end
