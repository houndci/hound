import UpgradeSubscriptionLink from '../../upgrade_subscription_link.js';

it('renders appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  }

  const wrapper = shallow(
    <UpgradeSubscriptionLink
      authenticityToken={"csrf_token"}
      repoId={repo.id}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
