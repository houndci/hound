import React from 'react';
import classNames from 'classnames';

import RepoActivationButton from './Repo/RepoActivationButton';
import RepoDeactivationButton from './Repo/RepoDeactivationButton';

export default class Repo extends React.Component {
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
    const { active, id, name, price_in_cents } = repo;
    const showPrivate = price_in_cents > 0;

    return (
      <li
        className={
          classNames(
            "repo",
            {"repo--active": active}
          )
        }
      >
        <div className="repo-name">
          {name}
        </div>

        { showPrivate &&
          <span className="badge margin-left-small">
            Private
          </span>
        }

        <div className="repo-activation-toggle">
          {this.renderButton()}
        </div>
      </li>
    );
  }
}

