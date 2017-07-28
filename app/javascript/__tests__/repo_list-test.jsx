import RepoList from '../repo_list.jsx';

it('renders a list of repos appropriately', () => {
  const repos = [
    {
      id: 1,
      name: "Test repo",
      owner: {
        id: 1
      }
    }
  ]

  const onRepoClicked = jest.fn();

  const wrapper = shallow(
    <RepoList
      repos={repos}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
      filterTerm={""}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
