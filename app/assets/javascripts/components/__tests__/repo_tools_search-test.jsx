import RepoToolsSearch from '../repo_tools_search.js';

it('renders appropriately', () => {
  const onSearchInput = jest.fn();

  const wrapper = shallow(
    <RepoToolsSearch onSearchInput={onSearchInput} />
  );
  expect(wrapper).toMatchSnapshot();
});
