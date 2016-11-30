import React from 'react';
import renderer from 'react-test-renderer';

import RepoToolsRefresh from '../repo_tools_refresh.js';

const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "meh"
  }
};

it('renders appropriately', () => {
  const onRefreshClicked = jest.genMockFunction();

  const component = renderer.create(
    <RepoToolsRefresh
      isSyncing={false}
      onRefreshClicked={onRefreshClicked}
    />
  );

  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
