import RepoActivationButton from '../../repo_activation_button.js';

it('renders a button appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  }

  const onRepoClicked = jest.genMockFunction();

  const wrapper = shallow(
    <RepoActivationButton
      repo={repo}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
