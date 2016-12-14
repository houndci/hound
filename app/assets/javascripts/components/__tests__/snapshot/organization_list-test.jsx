import OrganizationsList from '../../organizations_list.js';

it('renders a list of organizations appropriately', () => {
  const organizations = [
    { id: 1, name: "Test org" }
  ]
  const repos = [
    {
      id: 1,
      name: "Test repo",
      owner: {
        id: 1
      }
    }
  ]

  const onRepoClicked = jest.genMockFunction();

  const wrapper = shallow(
    <OrganizationsList
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
