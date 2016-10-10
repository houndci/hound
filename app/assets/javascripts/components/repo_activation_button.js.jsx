class RepoActivationButton extends React.Component {
  render() {
    const {
      repo,
      onRepoClicked,
      isProcessingId,
    } = this.props;
    const disabledState = (isProcessingId === repo.id) ? "disabled" : null;

    if (repo.admin) {
      return (
        <button
          className="repo-toggle"
          onClick={() => onRepoClicked(repo.id)}
          disabled={disabledState}
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
