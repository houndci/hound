require('./testdom')('<html><body></body></html>');

import React from 'react';
import TestUtils from 'react-addons-test-utils';
import assert from 'assert';

import EmptyRepoList from '../empty_repo_list.js';

describe('EmptyRepoList', function() {
  it('renders an empty unordered list', function() {
    TestUtils.renderIntoDocument(<EmptyRepoList />);

    assert.notEqual($('.repos'), null);
    assert.equal($('.repos').children().length, 0);
  });
});
