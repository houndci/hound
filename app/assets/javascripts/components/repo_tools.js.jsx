import RepoToolsSearch from './repo_tools_search.js';
import RepoToolsRefresh from './repo_tools_refresh.js';
import RepoToolsPrivate from './repo_tools_private.js';

class RepoTools extends React.Component {
  render() {
    const {
      onSearchInput,
      showPrivateButton,
      isSyncing,
      onRefreshClicked,
    } = this.props;

    return (
      <div className="repo-tools">
        <RepoToolsSearch onSearchInput={onSearchInput} />
        {showPrivateButton ? <RepoToolsPrivate /> : null}
        <RepoToolsRefresh
          isSyncing={isSyncing}
          onRefreshClicked={onRefreshClicked}
        />
      </div>
    );
  }
}

module.exports = RepoTools;
