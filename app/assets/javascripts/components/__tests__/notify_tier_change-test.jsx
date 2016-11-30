import React from 'react';
import renderer from 'react-test-renderer';

import NotifyTierChange from '../notify_tier_change.js';

it('renders plans appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo"
  }
  const plans = [
    {name: "Chihuahua", price: 49, allowance: 4, current: true},
    {name: "Labrador", price: 99, allowance: 10},
    {name: "Great Dane", price: 249, allowance: 30},
  ]

  const component = renderer.create(
    <NotifyTierChange
      authenticity_token = "csrf_token"
      plans = {plans}
      repo_id = {repo.id}
      repo_name = {repo.name}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
