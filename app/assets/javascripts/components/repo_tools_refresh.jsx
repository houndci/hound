class RepoToolsRefresh extends React.Component {
  refreshIcon(isSyncing) {
    if (isSyncing) {
      return " fa-spin";
    }
  }

  render() {
    const { isSyncing, onRefreshClicked } = this.props;

    return (
      <div className="repo-tools-refresh">
        <button
          className="repo-tools-refresh-button"
          disabled={isSyncing ? "disabled" : null}
          onClick={onRefreshClicked}
        >
          <span>
            <i className={"fa fa-refresh fa-fw" + this.refreshIcon(isSyncing)}></i>
          </span>
        </button>
      </div>
    );
  }
}

module.exports = RepoToolsRefresh;
