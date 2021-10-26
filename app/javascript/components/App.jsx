import React from 'react';

import { ReposProvider } from '../providers/ReposProvider';

import RepoListActions from './RepoListActions';
import OrgList from './OrgList';

const App = ({ appName }) => (
  <ReposProvider>
    <RepoListActions appName={appName} />
    <OrgList />
  </ReposProvider>
);

export default App;
