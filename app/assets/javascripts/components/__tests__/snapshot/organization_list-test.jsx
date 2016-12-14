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

  const component = renderer.create(
    <OrganizationsList
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
