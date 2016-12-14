import React from 'react';
import renderer from 'react-test-renderer';

import ReposContainer from '../../repos_container.js';

const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "meh"
  }
};

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
