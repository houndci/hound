import PopulatedRepoList from '../../populated_repo_list.js';

it('renders a list of repos appropriately', () => {
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
    <PopulatedRepoList
      repos={repos}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
      filterTerm={""}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
