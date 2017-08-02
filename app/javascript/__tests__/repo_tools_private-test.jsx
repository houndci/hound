/*jshint esversion: 6 */

import RepoToolsPrivate from '../components/ReposContainer/components/RepoTools/RepoToolsPrivate';

it('renders appropriately', () => {
  const wrapper = shallow(
    <RepoToolsPrivate />
  );
  expect(wrapper).toMatchSnapshot();
});
