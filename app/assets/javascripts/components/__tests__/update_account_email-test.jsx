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

// it('renders appropriately on successful email update', () => {
//   //const jQueryStub = sinon.stub($, 'ajax').yieldsTo('success');

//   const wrapper = mount(
//     <UpdateAccountEmail
//       addressChanged={false}
//     />
//   );

//   wrapper.find('.button-small').simulate('click');

//   expect(wrapper.find('.fa-check')).to.have.length(1);
//   expect(wrapper.props().addressChanged).toBe(true);

//   //jQueryStub.restore();
// });

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
