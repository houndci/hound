require 'test_helper'

class AngularRailsCsrfTest < ActionController::TestCase
  tests ApplicationController

  setup do
    @controller.allow_forgery_protection = true
    @correct_token = @controller.send(:form_authenticity_token)
  end

  test "a get sets the XSRF-TOKEN cookie but does not require the X-XSRF-TOKEN header" do
    get :index
    assert_equal @correct_token, cookies['XSRF-TOKEN']
    assert_response :success
  end

  test "a post raises an error without the X-XSRF-TOKEN header set" do
    assert_raises ActionController::InvalidAuthenticityToken do
      post :create
    end
  end

  test "a post raises an error with the X-XSRF-TOKEN header set to the wrong value" do
    @request.headers['X-XSRF-TOKEN'] = 'garbage'
    assert_raises ActionController::InvalidAuthenticityToken do
      post :create
    end
  end

  test "a post is accepted if X-XSRF-TOKEN is set properly" do
    @request.headers['X-XSRF-TOKEN'] = @correct_token
    post :create
    assert_response :success
  end
end
