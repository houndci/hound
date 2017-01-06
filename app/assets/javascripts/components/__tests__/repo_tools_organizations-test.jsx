import RepoToolsOrganizations from '../repo_tools_organizations.jsx';

it('renders a dropdown list containing organizations', () => {
  const organizations = [
    { id: 1, name: "Test org" }
  ]

  const wrapper = shallow(
    <RepoToolsOrganizations
      organizations={organizations}
    />
  );

  expect(wrapper).toMatchSnapshot();
});
