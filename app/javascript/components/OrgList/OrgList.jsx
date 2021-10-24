import React, { useContext } from 'react';
import { uniqBy } from 'lodash';

import { ReposContext } from '../../providers/ReposProvider';
import Organization from '../Organization';
import NoReposMessage from './NoReposMessage';
import ReposSyncSpinner from './ReposSyncSpinner';

const OrgList = () => {
  const { repos, isSyncing } = useContext(ReposContext);

  if (isSyncing) {
    return <ReposSyncSpinner/>;
  } else if (repos.length === 0) {
    return <NoReposMessage/>;
  } else {
    const orgs = uniqBy(repos.map((repo) => repo.owner), 'name');

    return (
      <section className="organizations">
        {orgs.map((org) => <Organization key={org.name} org={org} />)}
      </section>
    );
  }
}

export default OrgList;
