import UpgradeSubscriptionLink from '../../upgrade_subscription_link.js';

it('renders appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  }

  const component = renderer.create(
    <UpgradeSubscriptionLink
      authenticityToken={"csrf_token"}
      repoId={repo.id}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
