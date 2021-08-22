import React from 'react';

import SearchAction from './SearchAction';
import RefreshAction from './RefreshAction';
import AddAction from './AddAction';

const RepoListActions = ({ appName, setSearchTerm }) => (
  <div className="repo-tools">
    <AddAction appName={appName} />
    <RefreshAction />
    <SearchAction setSearchTerm={setSearchTerm} />
  </div>
);

export default RepoListActions;
