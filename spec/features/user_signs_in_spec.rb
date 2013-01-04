require 'spec_helper'

feature 'User authentication' do
  scenario 'user signs in successfully', js: true do
    visit root_path

    click_link 'Sign in'
    fill_in 'login_field', with: 'jimtom'
    fill_in 'password', with: '1testing'
    click_button 'Sign in'

    expect(page).to have_link 'Sign out'
  end

  scenario 'user signs out successfully', js: true do
    visit root_path

    click_link 'Sign in'
    fill_in 'login_field', with: 'jimtom'
    fill_in 'password', with: '1testing'
    click_button 'Sign in'
    click_link 'Sign out'

    expect(page).to have_link 'Sign in'
  end
end
