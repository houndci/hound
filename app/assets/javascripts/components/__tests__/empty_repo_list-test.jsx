import React from 'react';
import renderer from 'react-test-renderer';

import EmptyRepoList from '../empty_repo_list.js';

it('renders an empty unordered list', () => {
  const component = renderer.create(
    <EmptyRepoList />
  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
