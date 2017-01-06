import RepoToolsOrganizations from './repo_tools_organizations.jsx';
import RepoToolsSearch from './repo_tools_search.jsx';
import RepoToolsRefresh from './repo_tools_refresh.jsx';
import RepoToolsPrivate from './repo_tools_private.jsx';

class RepoTools extends React.Component {
  render() {
    const {
      onSearchInput,
      showPrivateButton,
      isSyncing,
      onRefreshClicked,
      organizations
    } = this.props;

    return (
      <div className="repo-tools">
        <RepoToolsSearch onSearchInput={onSearchInput} />
        {showPrivateButton ? <RepoToolsPrivate /> : null}
        <RepoToolsOrganizations organizations={organizations} />
        <RepoToolsRefresh
          isSyncing={isSyncing}
          onRefreshClicked={onRefreshClicked}
        />
      </div>
    );
  }
}

module.exports = RepoTools;
