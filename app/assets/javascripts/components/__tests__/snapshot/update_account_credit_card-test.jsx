import React from 'react';
import renderer from 'react-test-renderer';

import UpdateAccountCreditCard from '../../update_account_credit_card.js';

it('renders appropriately', () => {
  const component = renderer.create(
    <UpdateAccountCreditCard
      authenticity_token={"csrf_token"}
      stripe_customer_id_present={true}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
