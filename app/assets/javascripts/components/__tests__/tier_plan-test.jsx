import React from 'react';
import renderer from 'react-test-renderer';

import TierPlan from '../tier_plan.js';

it('renders appropriately (current plan)', () => {
  const plan = {
    name: "Chihuahua",
    price: 49,
    allowance: 4,
    current: true
  }

  const component = renderer.create(
    <TierPlan
      isCurrent={true}
      isNew={true}
      key={plan.name}
      plan={plan}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
