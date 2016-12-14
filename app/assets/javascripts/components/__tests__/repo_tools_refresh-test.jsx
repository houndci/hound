import RepoToolsRefresh from '../repo_tools_refresh.js';

it('renders appropriately', () => {
  const onRefreshClicked = jest.fn();

  const wrapper = shallow(
    <RepoToolsRefresh
      isSyncing={false}
      onRefreshClicked={onRefreshClicked}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it('renders appropriately (when syncing)', () => {
  const onRefreshClicked = jest.fn();

  const wrapper = shallow(
    <RepoToolsRefresh
      isSyncing={true}
      onRefreshClicked={onRefreshClicked}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
