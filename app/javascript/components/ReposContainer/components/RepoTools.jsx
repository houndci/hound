import React from 'react';

import RepoToolsSearch from './RepoTools/RepoToolsSearch';
import RepoToolsRefresh from './RepoTools/RepoToolsRefresh';
import RepoToolsAdd from './RepoTools/RepoToolsAdd';

export default class RepoTools extends React.Component {
  render() {
    const {
      appName,
      hasRepos,
      isSyncing,
      onSearchInput,
      onRefreshClicked,
    } = this.props;

    return (
      <div className="repo-tools">
        <RepoToolsAdd appName={appName} />
        <RepoToolsRefresh
          isSyncing={isSyncing}
          onRefreshClicked={onRefreshClicked}
        />
        {hasRepos && <RepoToolsSearch onSearchInput={onSearchInput} />}
      </div>
    );
  }
}
