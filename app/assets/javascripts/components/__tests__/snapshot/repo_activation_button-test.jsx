import React from 'react';
import renderer from 'react-test-renderer';

import RepoActivationButton from '../../repo_activation_button.js';

it('renders a button appropriately', () => {
  const repo = {
    id: 1,
    name: "Test repo",
    owner: {
      id: 1
    }
  }

  const onRepoClicked = jest.genMockFunction();

  const component = renderer.create(
    <RepoActivationButton
      repo={repo}
      onRepoClicked={onRepoClicked}
      isProcessingId={null}
    />

  );
  let tree = component.toJSON();
  expect(tree).toMatchSnapshot();
});
