import React from 'react'

import ReposSyncSpinner from './ReposView/ReposSyncSpinner'
import OrganizationsList from './ReposView/OrganizationsList'

export default class ReposView extends React.Component {
  render() {
    const {
      isSyncing,
      organizations,
      repos,
      filterTerm,
      onRepoClicked,
      isProcessingId
    } = this.props

    if (isSyncing) {
      return (
        <ReposSyncSpinner/>
      )
    } else {
      return (
        <OrganizationsList
          organizations={organizations}
          repos={repos}
          filterTerm={filterTerm}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
        />
      )
    }
  }
}
