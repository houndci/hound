/*jshint esversion: 6 */

import RepoToolsSearch from '../components/ReposContainer/components/RepoTools/RepoToolsSearch';

it('renders appropriately', () => {
  const onSearchInput = jest.fn();

  const wrapper = shallow(
    <RepoToolsSearch onSearchInput={onSearchInput} />
  );
  expect(wrapper).toMatchSnapshot();
});
