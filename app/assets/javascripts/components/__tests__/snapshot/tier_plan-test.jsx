import TierPlan from '../../tier_plan.js';

it('renders appropriately (current plan)', () => {
  const plan = {
    name: "Chihuahua",
    price: 49,
    allowance: 4,
    current: true
  }

  const wrapper = shallow(
    <TierPlan
      isCurrent={true}
      isNew={true}
      key={plan.name}
      plan={plan}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
