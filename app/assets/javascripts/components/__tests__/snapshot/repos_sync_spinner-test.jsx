import ReposSyncSpinner from '../../repos_sync_spinner.js';

it('renders appropriately', () => {
  const component = renderer.create(
    <ReposSyncSpinner />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
