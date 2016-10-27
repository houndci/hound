import React from 'react';

import ReposSyncSpinner from './repos_sync_spinner';
import OrganizationsList from './organizations_list';

class ReposView extends React.Component {
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
      return (
        <ReposSyncSpinner/>
      );
    } else {
      return (
        <OrganizationsList
          organizations={organizations}
          repos={repos}
          filterTerm={filterTerm}
          onRepoClicked={(evt) => onRepoClicked(evt)}
          isProcessingId={isProcessingId}
        />
      );
    }
  }
}

module.exports = ReposView;
