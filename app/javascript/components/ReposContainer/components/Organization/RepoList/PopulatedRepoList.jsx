import React from 'react'

import Repo from './../../Repo'

export default class PopulatedRepoList extends React.Component {
  canShow(repo) {
    const { filterTerm } = this.props

    if (filterTerm === null) {
      return true
    } else {
      const repoName = repo.name.toLowerCase()
      return repoName.indexOf(filterTerm.toLowerCase()) !== -1
    }
  }

  render() {
    const { repos, onRepoClicked, isProcessingId } = this.props

    return (
      <ul className="repos">
        {repos.filter(this.canShow.bind(this)).map( repo => (
          <Repo
            repo={repo}
            key={repo.id}
            onRepoClicked={onRepoClicked}
            isProcessingId={isProcessingId}
          />
        ))}
      </ul>
    )
  }
}
