import React from 'react'

export default class RepoDeactivationButton extends React.Component {
  constructor() {
    super()

    this.state = { buttonText: "Active" }
  }

  onMouseOutButton() {
    this.setState({ buttonText: "Active" })
  }

  onMouseOverButton() {
    this.setState({ buttonText: "Deactivate" })
  }

  getDisabledState() {
    const { isProcessingId, repo } = this.props
    const { id } = repo

    return (isProcessingId === id) ? "disabled" : null
  }

  render() {
    const { buttonText } = this.state
    const { repo, onRepoClicked } = this.props
    const { admin, id } = repo

    if (admin) {
      return (
        <button
          className="repo-toggle"
          disabled={this.getDisabledState()}
          onClick={() => onRepoClicked(id)}
          onMouseOut={() => this.onMouseOutButton()}
          onMouseOver={() => this.onMouseOverButton()}
        >
          {buttonText}
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
