require "rails_helper"

describe RepoSerializer do
  describe "#admin" do
    context "when current user is an admin of the repo" do
      it "returns true" do
        membership = create(:membership, admin: true)
        serializer = RepoSerializer.new(
          membership.repo,
          scope: membership.user,
          scope_name: :current_user,
        )

        expect(serializer.admin).to eq true
      end
    end

    context "when current user is not an admin of the repo" do
      it "returns false" do
        membership = create(:membership, admin: false)
        serializer = RepoSerializer.new(
          membership.repo,
          scope: membership.user,
          scope_name: :current_user,
        )

        expect(serializer.admin).to eq false
      end
    end

    context "when the current user is not a member of the repo" do
      context "and does not have a subscription for the repo" do
        it "returns false" do
          user = create(:user)
          repo = create(:repo)
          serializer = RepoSerializer.new(
            repo,
            scope: user,
            scope_name: :current_user,
          )

          expect(serializer.admin).to eq false
        end
      end

      context "and has a subscription for the repo" do
        it "returns true" do
          user = create(:user)
          repo = create(:repo)
          create(:subscription, user: user, repo: repo)
          serializer = RepoSerializer.new(
            repo,
            scope: user,
            scope_name: :current_user,
          )

          expect(serializer.admin).to eq true
        end
      end
    end
  end

  describe "#price_in_cents" do
    it "returns zero" do
      repo = create(:repo, private: false)
      membership = create(:membership, admin: true)
      user = membership.user
      serializer = RepoSerializer.new(
        repo,
        scope: user,
        scope_name: :current_user,
      )

      expect(serializer.price_in_cents).to be_zero
    end

    context "when the repo is private" do
      it "returns subscription price in cents if the repo were activated" do
        repo = create(:repo, private: true)
        membership = create(:membership, admin: true, repo: repo)
        user = membership.user
        serializer = RepoSerializer.new(
          repo,
          scope: user,
          scope_name: :current_user,
        )

        expect(serializer.price_in_cents).to eq(user.tier_price * 100)
      end
    end
  end
end
