import ReposSyncSpinner from '../components/ReposContainer/components/ReposView/ReposSyncSpinner';

it('renders appropriately', () => {
  const wrapper = shallow(
    <ReposSyncSpinner />
  );
  expect(wrapper).toMatchSnapshot();
});
