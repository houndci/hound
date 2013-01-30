require 'fast_spec_helper'
require 'app/services/style_checker'
require 'lib/github_api'

describe StyleChecker do
  describe '#check' do
    it 'sets GitHub status to pending' do
      api = mock(:create_pending_status)
      GithubApi.stubs(new: api)
      pull_request = stub
      checker = StyleChecker.new
      github_token = 'abc123'

      checker.check(pull_request, github_token)

      expect(GithubApi).to have_received(:new).with(github_token)
      expect(api).to have_received(:create_pending_status).
        with(pull_request, 'Hound is working...')
    end
  end
end
