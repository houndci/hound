require "spec_helper"

describe UpdateRepoOwner do
  context "with a repo with an owner_id" do
    it "does not update the repo" do
      repo = create(:repo)

      expect { UpdateRepoOwner.run }.not_to change { repo.updated_at }
    end
  end

  context "with a repo missing owner_id" do
    context "when the repo exists on github" do
      context "when owner exists" do
        it "assigns the owner to the repo" do
          owner = create(:owner, github_id: 154463) # from fixture
          repo = create(:repo, owner_id: nil)
          stub_repo_request(repo.name, ENV["HOUND_GITHUB_TOKEN"])

          UpdateRepoOwner.run

          expect(repo.reload.owner_id).to eq(owner.id)
        end
      end

      context "when owner does not exist" do
        it "creates the owner and assigns it to the repo" do
          owner_github_id = 154463 # from fixture
          repo = create(:repo, owner_id: nil)
          stub_repo_request(repo.name, ENV["HOUND_GITHUB_TOKEN"])

          UpdateRepoOwner.run
          new_owner = Owner.find_by(github_id: owner_github_id)

          expect(repo.reload.owner_id).to eq(new_owner.id)
        end
      end
    end

    context "when the repo does not exist on github" do
      it "does not update the repo" do
        repo = create(:repo, owner_id: nil)
        stub_not_found_repo_request(repo.name, ENV["HOUND_GITHUB_TOKEN"])

        expect { UpdateRepoOwner.run }.not_to change { repo.updated_at }
      end
    end
  end
end
