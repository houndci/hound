import ReposView from '../../repos_view.js';

it('renders appropriately', () => {
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

  const component = renderer.create(
    <ReposView
      isSyncing={false}
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={(event) => onRepoClicked}
      isProcessingId={null}
     />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
