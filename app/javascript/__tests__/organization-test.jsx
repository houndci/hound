/*jshint esversion: 6 */

import Organization from '../components/ReposContainer/components/Organization';

it('renders an organization with ID appropriately (no repo processing)', () => {
  const org = {
    id: 1,
    name: 'Test org'
  };
  const repos = [
    { id: 1, name: 'Test repo' }
  ];

  const wrapper = shallow(
    <Organization
      name={org.name}
      key={org.id}
      repos={repos}
      onRepoClicked={jest.fn()}
      filterTerm={''}
      isProcessingId={null}
    />
  );
  expect(wrapper).toMatchSnapshot();
});
