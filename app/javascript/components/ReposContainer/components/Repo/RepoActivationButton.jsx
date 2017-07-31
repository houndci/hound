/*jshint esversion: 6 */

import React from 'react'

export default class RepoActivationButton extends React.Component {
  get disabledState() {
    const { isProcessingId, repo } = this.props
    const { id } = repo

    return (isProcessingId === id) ? "disabled" : null
  }

  render() {
    const { repo, onRepoClicked } = this.props
    const { admin, id } = repo

    if (admin) {
      return (
        <button
          className="repo-toggle"
          onClick={() => onRepoClicked(id)}
          disabled={this.disabledState}
        >
          Activate
        </button>
      )
    } else {
      return (
        <div className="repo-restricted">
          Only repo admins can activate
        </div>
      )
    }
  }
}
