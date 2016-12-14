import UpdateAccountEmailMessage from '../../update_account_email_message.js';

it('renders appropriately', () => {
  const component = renderer.create(
    <UpdateAccountEmailMessage
      addressChanged={false}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
