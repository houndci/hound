/*jshint esversion: 6 */

import RepoToolsRefresh from '../components/ReposContainer/components/RepoTools/RepoToolsRefresh';

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
