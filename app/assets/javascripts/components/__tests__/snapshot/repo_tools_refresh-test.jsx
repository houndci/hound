import RepoToolsRefresh from '../../repo_tools_refresh.js';

it('renders appropriately', () => {
  const onRefreshClicked = jest.genMockFunction();

  const component = renderer.create(
    <RepoToolsRefresh
      isSyncing={false}
      onRefreshClicked={onRefreshClicked}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
