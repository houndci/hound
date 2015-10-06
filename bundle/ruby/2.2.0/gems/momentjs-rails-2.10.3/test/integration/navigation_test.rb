require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  test 'can access momentjs' do
    get '/assets/moment.js'
    assert_response :success
  end

  test 'momentjs response is for the expected version' do
    get '/assets/moment.js'
    assert_match(/utils_hooks__hooks.version = '2\.10\.3'/, @response.body)
  end

  test 'can access momentjs translation' do
    get '/assets/moment/fr.js'
    assert_response :success
  end
end
