require 'test_helper'

class FontAwesomeRailsTest < ActionDispatch::IntegrationTest
  teardown { clean_sprockets_cache }

  test "engine is loaded" do
    assert_equal ::Rails::Engine, FontAwesome::Rails::Engine.superclass
  end

  test "fonts are served" do
    get "/assets/fontawesome-webfont.eot"
    assert_response :success
    get "/assets/fontawesome-webfont.woff2"
    assert_response :success
    get "/assets/fontawesome-webfont.woff"
    assert_response :success
    get "/assets/fontawesome-webfont.ttf"
    assert_response :success
    get "/assets/fontawesome-webfont.svg"
    assert_response :success
  end

  test "stylesheets are served" do
    get "/assets/font-awesome.css"
    assert_font_awesome(response)
  end

  test "stylesheets contain asset pipeline references to fonts" do
    get "/assets/font-awesome.css"
    v = FontAwesome::Rails::FA_VERSION
    assert_match "/assets/fontawesome-webfont.eot?v=#{v}",  response.body
    assert_match "/assets/fontawesome-webfont.eot?#iefix&v=#{v}", response.body
    assert_match "/assets/fontawesome-webfont.woff2?v=#{v}", response.body
    assert_match "/assets/fontawesome-webfont.woff?v=#{v}", response.body
    assert_match "/assets/fontawesome-webfont.ttf?v=#{v}",  response.body
    assert_match "/assets/fontawesome-webfont.svg?v=#{v}#fontawesomeregular", response.body
  end

  test "stylesheet is available in a css sprockets require" do
    get "/assets/sprockets-require.css"
    assert_font_awesome(response)
  end

  test "stylesheet is available in a sass import" do
    get "/assets/sass-import.css"
    assert_font_awesome(response)
  end

  test "stylesheet is available in a scss import" do
    get "/assets/scss-import.css"
    assert_font_awesome(response)
  end

  test "helpers should be available in the view" do
    get "/icons"
    assert_response :success
    assert_select "i.fa.fa-flag"
    assert_select "span.fa-stack"
  end

  private

  def clean_sprockets_cache
    FileUtils.rm_rf File.expand_path("../dummy/tmp",  __FILE__)
  end

  def assert_font_awesome(response)
    assert_response :success
    assert_match(/font-family:\s*'FontAwesome';/, response.body)
  end
end
