require 'test_helper'

class StaticFileServiceTest < ActiveSupport::IntegrationCase
  test 'renders CSS' do
    visit "/assets/application-5f55f638b632759d9c9113417c3ac6bd.css"
    assert_equal 200, page.status_code
  end

  test 'renders JS' do
    visit "/assets/application-89f8f774b6fb6783dfccc79d4103f256.js"
    assert_equal 200, page.status_code
  end

  test 'renders images' do
    visit "/assets/schneems-cb0905b917bde936182e153558f54a5f.png"
    assert_equal 200, page.status_code
  end

  test 'does not render imaginary things' do
    visit "/assets/does-not-exist.png"
    refute_equal 200, page.status_code
  end
end
