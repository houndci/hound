class HomeController < ApplicationController
  skip_before_action :authenticate, only: [:index]

  before_action :redirect_to_repos, if: :signed_in?

  def index
    @home = Home.new(current_user || guest)
    @experiment = ab_test(:home, ["original", "simple", "get_started_cta"])
    @companies = YAML.safe_load(File.read("config/companies.yml"))
    @languages = YAML.safe_load(File.read("config/languages.yml"))
  end

  private

  def redirect_to_repos
    redirect_to repos_path
  end

  def guest
    User.new
  end
end
