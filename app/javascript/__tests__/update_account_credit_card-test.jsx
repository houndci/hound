/*jshint esversion: 6 */

import UpdateAccountCreditCard from '../components/UpdateAccountCreditCard';

it('renders appropriately', () => {
  const wrapper = shallow(
    <UpdateAccountCreditCard
      authenticity_token={"csrf_token"}
      stripe_customer_id_present={true}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it('renders appropriately without Stripe customer ID', () => {
  const wrapper = shallow(
    <UpdateAccountCreditCard
      authenticity_token={"csrf_token"}
      stripe_customer_id_present={false}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

