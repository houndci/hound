import RepoToolsPrivate from '../../repo_tools_private.js';

it('renders appropriately', () => {
  const wrapper = shallow(
    <RepoToolsPrivate />
  );
  expect(wrapper).toMatchSnapshot();
});
