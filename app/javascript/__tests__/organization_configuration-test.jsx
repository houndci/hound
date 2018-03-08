import OrganizationConfiguration from "../components/ReposContainer/components/Organization/OrganizationConfiguration";

const ownerId = 1;
const repos = [
  {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  },
  {
    id: 2,
    name: "Test repo 2",
    owner: {
      id: 1
    }
  }
];

describe("with a user that is not an organization owner", () => {
  const userIsOrgOwner = false;

  describe("and when config is disabled", () => {
    it("renders a config is disabled message", () => {
      const configEnabled = false;
      const configRepo = null;

      const wrapper = shallow(
        <OrganizationConfiguration
          enabled={configEnabled}
          id={ownerId}
          repo={configRepo}
          repos={repos}
          userIsOrgOwner={userIsOrgOwner}
        />
      );
      expect(wrapper).toMatchSnapshot();
    });
  });

  describe("and when config is enabled but a repo has not been set", () => {
    it("renders a config is disabled message", () => {
      const configEnabled = true;
      const configRepo = null;

      const wrapper = shallow(
        <OrganizationConfiguration
          enabled={configEnabled}
          id={ownerId}
          repo={configRepo}
          repos={repos}
          userIsOrgOwner={userIsOrgOwner}
        />
      );
      expect(wrapper).toMatchSnapshot();
    });
  });

  describe("and when config is enabled and a config repo is set", () => {
    it("renders a config is enabled message", () => {
      const configEnabled = true;
      const configRepo = 'Test repo 2';

      const wrapper = shallow(
        <OrganizationConfiguration
          enabled={configEnabled}
          id={ownerId}
          repo={configRepo}
          repos={repos}
          userIsOrgOwner={userIsOrgOwner}
        />
      );
      expect(wrapper).toMatchSnapshot();
    });
  });
});

describe("with a user that is an organization owner", () => {
  const userIsOrgOwner = true;

  describe("and when config is disabled", () => {
    it("renders the appropriate config options", () => {
      const configEnabled = false;
      const configRepo = null;

      const wrapper = shallow(
        <OrganizationConfiguration
          enabled={configEnabled}
          id={ownerId}
          repo={configRepo}
          repos={repos}
          userIsOrgOwner={userIsOrgOwner}
        />
      );
      expect(wrapper).toMatchSnapshot();
    });
  });

  describe("and when config is enabled but a repo has not been set", () => {
    it("renders the appropriate config options", () => {
      const configEnabled = true;
      const configRepo = null;

      const wrapper = shallow(
        <OrganizationConfiguration
          enabled={configEnabled}
          id={ownerId}
          repo={configRepo}
          repos={repos}
          userIsOrgOwner={userIsOrgOwner}
        />
      );
      expect(wrapper).toMatchSnapshot();
    });
  });

  describe("and when config is enabled and a config repo is set", () => {
    it("renders the appropriate config options", () => {
      const configEnabled = true;
      const configRepo = 'Test repo 2';

      const wrapper = shallow(
        <OrganizationConfiguration
          enabled={configEnabled}
          id={ownerId}
          repo={configRepo}
          repos={repos}
          userIsOrgOwner={userIsOrgOwner}
        />
      );
      expect(wrapper).toMatchSnapshot();
    });
  });
});
