import React from 'react';

import SearchAction from './SearchAction';
import RefreshAction from './RefreshAction';
import AddAction from './AddAction';

const RepoListActions = ({ appName }) => {
  return (
    <div className="repo-tools">
      <AddAction appName={appName} />
      <RefreshAction />
      <SearchAction />
    </div>
  );
}

export default RepoListActions;
