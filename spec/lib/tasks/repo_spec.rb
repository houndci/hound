require "rails_helper"
require "rake"

describe "namespace repo" do
  before :all do
    Rake.application.rake_require "tasks/repo"
    Rake::Task.define_task(:environment)
  end

  describe "task remove_without_memberships" do
    it "removes repos without memberships" do
      repo = create(:repo)
      create(:membership, repo: repo)
      create(:repo).tap do |r|
        r.memberships.destroy_all
      end

      task = Rake::Task["repo:remove_without_memberships"]
      task.reenable
      task.invoke

      expect(Repo.all).to eq([repo])
    end
  end
end
