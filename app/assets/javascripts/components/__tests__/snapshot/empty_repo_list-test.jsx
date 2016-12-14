import EmptyRepoList from '../../empty_repo_list.js';

it('renders an empty unordered list', () => {
  const wrapper = shallow(
    <EmptyRepoList />
  );
  expect(wrapper).toMatchSnapshot();
});
