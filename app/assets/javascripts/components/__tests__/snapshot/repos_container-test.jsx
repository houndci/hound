import ReposContainer from '../../repos_container.js';

it('renders appropriately', () => {
  const onRefreshClicked = jest.genMockFunction();

  const wrapper = shallow(
    <ReposContainer
      authenticity_token={"csrf_token"}
      has_private_access={false}
      userHasCard={false}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
