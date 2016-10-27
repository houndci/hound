import React from 'react';

class RepoToolsRefresh extends React.Component {
  get isSyncing() {
    return this.props.isSyncing;
  }

  get disabledState() {
    return (this.isDisabled ? "disabled" : null);
  }

  render() {
    const { onRefreshClicked } = this.props;

    if (this.isSyncing) {
      var buttonText = Hound.settings.syncingButtonText;
    } else {
      var buttonText = Hound.settings.syncNowButtonText;
    }

    return (
      <div className="repo-tools-refresh">
        <button
          className="repo-tools-refresh-button"
          disabled={this.disabledState}
          onClick={onRefreshClicked}
        >
          <span>{buttonText}</span>
        </button>
      </div>
    );
  }
}

module.exports = RepoToolsRefresh;
