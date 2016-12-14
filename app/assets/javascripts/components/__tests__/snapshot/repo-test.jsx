import Repo from '../../repo.js';

it('renders a repo appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  }

  const onRepoClicked = jest.genMockFunction();

  const component = renderer.create(
    <Repo
      repo={repo}
      key={repo.id}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
