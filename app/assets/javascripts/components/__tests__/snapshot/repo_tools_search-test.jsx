import RepoToolsSearch from '../../repo_tools_search.js';

it('renders appropriately', () => {
  const onSearchInput = jest.genMockFunction();

  const component = renderer.create(
    <RepoToolsSearch onSearchInput={onSearchInput} />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
