import RepoTools from '../../repo_tools.js';

it('renders appropriately without Show Private button (not syncing)', () => {
  const has_private_access = true;

  const onSearchInput = jest.genMockFunction();
  const onRefreshClicked = jest.genMockFunction();
  const onPrivateClicked = jest.genMockFunction();

  const component = renderer.create(
    <RepoTools
      showPrivateButton={!has_private_access}
      onSearchInput={(event) => onSearchInput}
      onRefreshClicked={(event) => onRefreshClicked}
      onPrivateClicked={(event) => onPrivateClicked}
      isSyncing={false}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
