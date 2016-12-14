import ReposSyncSpinner from '../../repos_sync_spinner.js';

it('renders appropriately', () => {
  const wrapper = shallow(
    <ReposSyncSpinner />
  );
  expect(wrapper).toMatchSnapshot();
});
