import React from 'react';
import {shallow} from 'enzyme';
import renderer from 'react-test-renderer';

import RepoTools from '../../repo_tools.js';

const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "meh"
  }
};

it('renders appropriately without Show Private button (not syncing)', () => {
  const has_private_access = true;

  const onSearchInput = jest.genMockFunction();
  const onRefreshClicked = jest.genMockFunction();
  const onPrivateClicked = jest.genMockFunction();

  const component = renderer.create(
    <RepoTools
      showPrivateButton={!has_private_access}
      onSearchInput={(event) => onSearchInput}
      onRefreshClicked={(event) => onRefreshClicked}
      onPrivateClicked={(event) => onPrivateClicked}
      isSyncing={false}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
