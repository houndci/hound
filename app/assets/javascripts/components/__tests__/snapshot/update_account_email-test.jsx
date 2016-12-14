import UpdateAccountEmail from '../../update_account_email.js';

it('renders appropriately', () => {
  const component = renderer.create(
    <UpdateAccountEmail
      addressChanged={false}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
