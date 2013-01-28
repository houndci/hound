require 'fast_spec_helper'
require 'app/services/repo_activator'

describe RepoActivator do
  describe '#activate' do
    it 'creates GitHub hook' do
      api = mock(:create_pull_request_hook)
      relation = stub(where: [], create: nil)
      activator = RepoActivator.new

      activator.activate(123, 'jimtom/repo', relation, api, 'http://example.com')

      expect(api).to have_received(:create_pull_request_hook).
        with('jimtom/repo', 'http://example.com/builds')
    end
  end
end
