import React from 'react'

export default class RepoToolsRefresh extends React.Component {
  buttonText(isSyncing) {
    if (isSyncing) {
      return Hound.settings.syncingButtonText
    } else {
      return Hound.settings.syncNowButtonText
    }
  }

  render() {
    const { isSyncing, onRefreshClicked } = this.props

    return (
      <div className="repo-tools-refresh">
        <button
          className="repo-tools-refresh-button"
          disabled={isSyncing ? "disabled" : null}
          onClick={onRefreshClicked}
        >
          <span>{this.buttonText(isSyncing)}</span>
        </button>
      </div>
    )
  }
}
