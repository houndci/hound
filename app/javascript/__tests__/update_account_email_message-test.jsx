/*jshint esversion: 6 */

import UpdateAccountEmailMessage from '../components/UpdateAccountEmail/components/UpdateAccountEmailMessage';

it('renders appropriately', () => {
  const wrapper = shallow(
    <UpdateAccountEmailMessage
      addressChanged={false}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it('renders appropriately', () => {
  const wrapper = shallow(
    <UpdateAccountEmailMessage
      addressChanged={true}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
