import React from 'react';

import PopulatedRepoList from './populated_repo_list';
import EmptyRepoList from './empty_repo_list';

class RepoList extends React.Component {
  render() {
    const {
      repos,
      onRepoClicked,
      isProcessingId,
      filterTerm,
    } = this.props;

    if (repos.length > 0) {
      return (
        <PopulatedRepoList
          repos={repos}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
          filterTerm={filterTerm}
        />
      );
    } else {
      return (
        <EmptyRepoList />
      );
    }
  }
}

module.exports = RepoList;
