import React from 'react';

import ReposSyncSpinner from './ReposView/ReposSyncSpinner';
import OrganizationsList from './ReposView/OrganizationsList';
import NoReposMessage from './ReposView/NoReposMessage';

export default class ReposView extends React.Component {
  render() {
    const {
      isSyncing,
      organizations,
      repos,
      filterTerm,
      onRepoClicked,
      isProcessingId
    } = this.props;

    if (isSyncing) {
      return <ReposSyncSpinner/>;
    } else if (repos.length === 0) {
      return <NoReposMessage/>;
    } else {
      return (
        <OrganizationsList
          organizations={organizations}
          repos={repos}
          filterTerm={filterTerm}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
        />
      );
    }
  }
}
