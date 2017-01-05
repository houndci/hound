import UpdateAccountEmailMessage from '../update_account_email_message.js';

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
