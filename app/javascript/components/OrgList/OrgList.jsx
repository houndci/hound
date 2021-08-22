import React, { useContext } from 'react';
import { uniqBy } from 'lodash';

import { ReposContext } from '../../providers/ReposProvider';
import Organization from '../Organization';
import NoReposMessage from './NoReposMessage';
import ReposSyncSpinner from './ReposSyncSpinner';

const OrgList = () => {
  const { repos, searchTerm, isSyncing } = useContext(ReposContext);

  if (isSyncing) {
    return <ReposSyncSpinner/>;
  } else if (repos.length === 0) {
    return <NoReposMessage/>;
  } else {
    const orgs = uniqBy(repos.map((repo) => repo.owner), 'name');
    const getReposForOrg = (org) =>
      repos.filter((repo) => repo.owner.id === org.id);

    return (
      <section className="organizations">
        {orgs.map((org) => (
          <Organization
            key={org.name}
            org={org}
            repos={getReposForOrg(org)}
            searchTerm={searchTerm}
          />
        ))}
      </section>
    );
  }
}

export default OrgList;
