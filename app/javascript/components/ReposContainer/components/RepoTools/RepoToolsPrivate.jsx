import React from 'react';

export default class RepoToolsPrivate extends React.Component {
  render() {
    const { onPrivateClicked } = this.props;

    return (
      <div className="repo-tools-private">
        <form method="get" action="https://github.com/apps/hound/installations/new">
          <button
            className="repo-tools-private-button"
            type="submit"
            onClick={onPrivateClicked}
          >
            <span>Include private repos</span>
          </button>
        </form>
      </div>
    );
  }
}
