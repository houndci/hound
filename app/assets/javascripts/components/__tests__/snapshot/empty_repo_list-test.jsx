import EmptyRepoList from '../../empty_repo_list.js';

it('renders an empty unordered list', () => {
  const component = renderer.create(
    <EmptyRepoList />
  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
