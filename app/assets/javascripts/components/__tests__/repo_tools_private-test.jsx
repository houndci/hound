import RepoToolsPrivate from '../repo_tools_private.jsx';

it('renders appropriately', () => {
  const wrapper = shallow(
    <RepoToolsPrivate />
  );
  expect(wrapper).toMatchSnapshot();
});
