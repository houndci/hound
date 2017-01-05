import UpdateAccountEmail from '../update_account_email.js';

it('renders appropriately', () => {
  const wrapper = shallow(
    <UpdateAccountEmail
      addressChanged={false}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it('renders appropriately on address change', () => {
  const wrapper = shallow(
    <UpdateAccountEmail
      addressChanged={true}
    />
  );
  expect(wrapper).toMatchSnapshot();
});

it('sets state appropriately on email input', () => {
  const wrapper = mount(
    <UpdateAccountEmail
      addressChanged={false}
    />
  );

  const emailInput = wrapper.find('#email_address');
  emailInput.simulate('change', {target: {value: "new text"}});

  expect(wrapper.state('emailInput')).toBe('new text');
  expect(wrapper.state('addressChanged')).toBe(null);
});
