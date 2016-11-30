import React from 'react';
import renderer from 'react-test-renderer';

import RepoToolsSearch from '../repo_tools_search.js';

const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "meh"
  }
};

it('renders appropriately', () => {
  const onSearchInput = jest.genMockFunction();

  const component = renderer.create(
    <RepoToolsSearch onSearchInput={onSearchInput} />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
