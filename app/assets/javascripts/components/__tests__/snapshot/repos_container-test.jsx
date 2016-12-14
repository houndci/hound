import ReposContainer from '../../repos_container.js';

it('renders appropriately', () => {
  const onRefreshClicked = jest.genMockFunction();

  const component = renderer.create(
    <ReposContainer
      authenticity_token={"csrf_token"}
      has_private_access={false}
      userHasCard={false}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
