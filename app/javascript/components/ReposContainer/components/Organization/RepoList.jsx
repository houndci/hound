/*jshint esversion: 6 */

import React from 'react'

import EmptyRepoList from './RepoList/EmptyRepoList'
import PopulatedRepoList from './RepoList/PopulatedRepoList'

export default class RepoList extends React.Component {
  render() {
    const {
      repos,
      onRepoClicked,
      isProcessingId,
      filterTerm,
    } = this.props

    if (repos.length > 0) {
      return (
        <PopulatedRepoList
          repos={repos}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
          filterTerm={filterTerm}
        />
      )
    } else {
      return (
        <EmptyRepoList />
      )
    }
  }
}
