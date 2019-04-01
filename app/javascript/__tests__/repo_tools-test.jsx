import RepoTools from '../components/ReposContainer/components/RepoTools';

describe('RepoTools component', () => {
  describe('when user has no repos', () => {
    it('renders without search', () => {
      const hasRepos = false;

      const wrapper = shallow(
        <RepoTools
          isSyncing={false}
          hasRepos={hasRepos}
          onRefreshClicked={(event) => jest.fn()}
          onSearchInput={(event) => jest.fn()}
        />
      );

      expect(wrapper).toMatchSnapshot();
    });
  });

  describe('when user has repos', () => {
    it('renders with search', () => {
      const hasRepos = true;

      const wrapper = shallow(
        <RepoTools
          isSyncing={false}
          hasRepos={hasRepos}
          onRefreshClicked={(event) => jest.fn()}
          onSearchInput={(event) => jest.fn()}
        />
      );

      expect(wrapper).toMatchSnapshot();
    });
  });
});
