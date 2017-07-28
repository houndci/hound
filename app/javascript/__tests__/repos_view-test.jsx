import ReposView from '../components/ReposContainer/components/ReposView';

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

  const wrapper = shallow(
    <ReposView
      isSyncing={false}
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={(event) => onRepoClicked}
      isProcessingId={null}
     />
  );
  expect(wrapper).toMatchSnapshot();
});
