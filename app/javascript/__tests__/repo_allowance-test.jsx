import RepoAllowance from '../components/ReposContainer/components/RepoAllowance';

it('renders the allowance header', () => {
  const wrapper = shallow(
    <RepoAllowance
      subscribedRepoCount={4}
      tierAllowance={10}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
