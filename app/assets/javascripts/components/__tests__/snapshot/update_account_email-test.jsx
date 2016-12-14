import UpdateAccountEmail from '../../update_account_email.js';

it('renders appropriately', () => {
  const wrapper = shallow(
    <UpdateAccountEmail
      addressChanged={false}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
