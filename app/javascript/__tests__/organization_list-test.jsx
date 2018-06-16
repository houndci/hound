import OrganizationsList from "../components/ReposContainer/components/ReposView/OrganizationsList";
import Organization from "../components/ReposContainer/components/Organization";

it("renders a list of organizations appropriately", () => {
  const organizations = [
    { id: 1, name: "Test org" }
  ];
  const repos = [
    {
      id: 1,
      name: "Test repo",
      owner: {
        id: 1
      }
    }
  ];

  const wrapper = shallow(
    <OrganizationsList
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={jest.fn()}
      isProcessingId={null}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it("filters a list of organizations appropriately", () => {
  const organizations = [
    { id: 1, name: "Test org 1" },
    { id: 2, name: "Test org 2" },
    { id: 3, name: "Test org 3" },
  ];

  const repos = [
    {
      id: 1,
      name: "Test repo",
      owner: {
        id: 2
      }
    }
  ];

  const wrapper = mount(
    <OrganizationsList
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={jest.fn()}
      isProcessingId={null}
    />
  );
  const organizationsFound = wrapper.find(Organization).getElements();
  expect(organizationsFound.length).toBe(3);

  expect(organizationsFound[0].props.name).toBe("Test org 1");
  expect(organizationsFound[0].props.repos.length).toBe(0);

  expect(organizationsFound[1].props.name).toBe("Test org 2");
  expect(organizationsFound[1].props.repos.length).toBe(1);
  expect(organizationsFound[1].props.repos[0].id).toBe(1);

  expect(organizationsFound[2].props.name).toBe("Test org 3");
  expect(organizationsFound[2].props.repos.length).toBe(0);
});

it("filters a list of organizations appropriately", () => {
  const organizations = [
    { name: "S.H.I.E.L.D." },
    { name: "H.A.M.M.E.R." },
    { name: "Hydra" },
  ];

  const repos = [
    {
      id: 666,
      name: "Hydra/deathray",
    }
  ];

  const wrapper = mount(
    <OrganizationsList
      organizations={organizations}
      repos={repos}
      filterTerm={""}
      onRepoClicked={jest.fn()}
      isProcessingId={null}
    />
  );
  const organizationsFound = wrapper.find(Organization).getElements();
  expect(organizationsFound.length).toBe(3);

  expect(organizationsFound[0].props.name).toBe("S.H.I.E.L.D.");
  expect(organizationsFound[0].props.repos.length).toBe(0);

  expect(organizationsFound[1].props.name).toBe("H.A.M.M.E.R.");
  expect(organizationsFound[1].props.repos.length).toBe(0);

  expect(organizationsFound[2].props.name).toBe("Hydra");
  expect(organizationsFound[2].props.repos.length).toBe(1);
  expect(organizationsFound[2].props.repos[0].name).toBe("Hydra/deathray");
});
