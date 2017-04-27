import UpgradeSubscriptionLink from '../upgrade_subscription_link.jsx';
import * as Ajax from '../../lib/ajax.jsx';

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


it('renders appropriately', () => {
  const ajaxSpy = sinon.spy(Ajax, 'upgradeSubscription');
  const nextTier = { price: 49, title: "Chihuahua" }

  const wrapper = mount(
    <UpgradeSubscriptionLink
      authenticityToken={"csrf_token"}
      nextTier={nextTier}
      repoId={1}
      userHasCard={true}
    />
  );

  wrapper.find('.repo-toggle').simulate('click');

  expect(ajaxSpy.calledOnce).toBe(true);
  expect(ajaxSpy.calledWith(1)).toBe(true);
});
