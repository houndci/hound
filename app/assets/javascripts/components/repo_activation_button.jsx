import React from 'react';

class RepoActivationButton extends React.Component {
  get disabledState() {
    return (this.props.isProcessingId === this.props.repo.id) ? "disabled" : null;
  }

  render() {
    const {
      repo,
      onRepoClicked,
      isProcessingId,
    } = this.props;

    if (repo.admin) {
      return (
        <button
          className="repo-toggle"
          onClick={() => onRepoClicked(repo.id)}
          disabled={this.disabledState}
        >
        </button>
      );
    } else {
      return (
        <div className="repo-restricted">
          Only repo admins can activate
        </div>
      );
    }
  }
}

module.exports = RepoActivationButton;
