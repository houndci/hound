require 'spec_helper'

describe NullRepo do
  describe '#activate' do
    it 'creates an active repo' do
      user = FactoryGirl.create(:user)
      repo = NullRepo.new(user: user, github_id: 456)

      repo.activate

      active_repo = user.repos.where(github_id: 456, active: true)
      expect(active_repo).to_not be_nil
    end
  end
end
