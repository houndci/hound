import Repo from '../repo.js';

it('renders a repo appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  }

  const onRepoClicked = jest.fn();

  const wrapper = shallow(
    <Repo
      repo={repo}
      key={repo.id}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
