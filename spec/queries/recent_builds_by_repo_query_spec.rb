require "rails_helper"

describe RecentBuildsByRepoQuery do
  describe ".call" do
    it "returns the most recent build for each repo" do
      user = create(:user)
      repo1 = create(:membership, user: user).repo
      repo2 = create(:membership, user: user).repo
      recent_build1 = create(:build, pull_request_number: 1, repo: repo1)
      _old_build1 = create(
        :build,
        pull_request_number: 1,
        repo: repo1,
        created_at: 1.hour.ago,
      )
      recent_build2 = create(:build, pull_request_number: 2, repo: repo2)
      _old_build2 = create(
        :build,
        pull_request_number: 2,
        repo: repo2,
        created_at: 1.hour.ago,
      )

      builds = RecentBuildsByRepoQuery.call(user: user)

      expect(builds).to match_array [recent_build1, recent_build2]
    end

    it "returns builds ordered by created_at descending" do
      user = create(:user)
      repo1 = create(:membership, user: user).repo
      repo2 = create(:membership, user: user).repo
      build1 = create(:build, pull_request_number: 1, repo: repo1)
      build2 = create(:build, pull_request_number: 2, repo: repo2)

      builds = RecentBuildsByRepoQuery.call(user: user)

      expect(builds).to eq [build2, build1]
    end

    it "returns recent builds" do
      user = create(:user)
      repo1 = create(:membership, user: user).repo
      repo2 = create(:membership, user: user).repo
      create(:build, repo: repo1)
      build2 = create(:build, repo: repo2)
      stub_const("RecentBuildsByRepoQuery::NUMBER_OF_BUILDS", 1)

      builds = RecentBuildsByRepoQuery.call(user: user)

      expect(builds).to eq [build2]
    end
  end
end
