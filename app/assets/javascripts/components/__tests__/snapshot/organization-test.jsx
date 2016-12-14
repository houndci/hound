import Organization from '../../organization.js';

it('renders an organization with ID appropriately (no repo processing)', () => {
  const org = {
    id: 1,
    name: "Test org"
  }
  const repos = [
    {id: 1, name: "Test repo"}
  ]

  const onRepoClicked = jest.genMockFunction();

  const component = renderer.create(
    <Organization
      name={org.name}
      key={org.id}
      repos={repos}
      onRepoClicked={onRepoClicked}
      filterTerm={""}
      isProcessingId={null}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
