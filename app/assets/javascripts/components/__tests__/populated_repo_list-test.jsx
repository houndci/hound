import PopulatedRepoList from '../populated_repo_list.js';

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

  const wrapper = shallow(
    <PopulatedRepoList
      repos={repos}
      onRepoClicked={jest.fn()}
      isProcessingId={null}
      filterTerm={null}
    />
  );
  expect(wrapper).toMatchSnapshot();

  const wrapper2 = shallow(
    <PopulatedRepoList
      repos={repos}
      onRepoClicked={jest.fn()}
      isProcessingId={null}
      filterTerm={""}
    />
  );
  expect(wrapper2).toMatchSnapshot();
});

it('filters a list of repos appropriately', () => {
  const organizations = [
    { name: "S.H.I.E.L.D." },
    { name: "H.A.M.M.E.R." },
    { name: "Hydra" },
  ]
  const repos = [
    {
      id: 666,
      name: "Hydra/deathray",
    },
    {
      id: 302,
      name: "S.H.I.E.L.D./tesseract",
    },
    {
      id: 302,
      name: "H.A.M.M.E.R./iron_man_suit_knockoff",
    }
  ]

  const wrapper = shallow(
    <PopulatedRepoList
      repos={repos}
      onRepoClicked={jest.fn()}
      isProcessingId={null}
      filterTerm={"Hydra"}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
