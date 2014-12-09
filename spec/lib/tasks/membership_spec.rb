require "spec_helper"
require "rake"

describe "namespace membership" do
  before :all do
    Rake.application.rake_require "tasks/membership"
    Rake::Task.define_task(:environment)
  end

  describe "task cleanup_duplicates" do
    before do
      @user1 = create :user
      create :membership, user: @user1
      create :membership, user: @user1

      @user2 = create :user
      repo = create :repo
      create :membership, user: @user2, repo: repo
      create :membership, user: @user2, repo: repo
      create :membership, user: @user2, repo: repo
      create :membership, user: @user2

      task = Rake::Task["membership:cleanup_duplicates"]
      task.reenable
      task.invoke
    end

    it "cleans up duplicates" do
      expect(@user2.repos.count).to eq(2)
    end

    it "does not alter user without duplicates" do
      expect(@user1.repos.count).to eq(2)
    end
  end
end
