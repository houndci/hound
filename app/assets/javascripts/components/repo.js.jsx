import RepoActivationButton from './repo_activation_button.js';

class Repo extends React.Component {
  renderButton() {
    const { isProcessingId, repo, onRepoClicked } = this.props;
    const { active } = repo;

    if (active) {
      return (
        <RepoDeactivationButton
          repo={repo}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
        />
      );
    } else {
      return (
        <RepoActivationButton
          repo={repo}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
        />
      );
    }
  }

  render() {
    const { isProcessingId, repo } = this.props;
    const { active, id, name, price_in_cents } = repo

    const showPrivate = !active && price_in_cents > 0;

    return (
      <li
        className={
          classNames(
            "repo",
            {"repo--active": active},
            {"repo--processing": isProcessingId === id}
          )
        }
      >
        <div className="repo-name">
          {name}
        </div>

        <div className={classNames(
          "repo-activation-toggle",
          {"repo-activation-toggle--private": showPrivate}
        )}>
          {this.renderButton()}
        </div>
      </li>
    );
  }
}

module.exports = Repo;
