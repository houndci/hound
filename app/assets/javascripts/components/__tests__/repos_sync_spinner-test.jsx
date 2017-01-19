import ReposSyncSpinner from '../repos_sync_spinner.jsx';

it('renders appropriately', () => {
  const wrapper = shallow(
    <ReposSyncSpinner />
  );
  expect(wrapper).toMatchSnapshot();
});
