import React, { useContext } from 'react';

import { ReposContext } from '../../providers/ReposProvider';
import Configuration from './Configuration';
import Repos from './Repos';

const Organization = ({ org }) => {
  const {
    id,
    name,
    config_enabled: configEnabled,
    config_repo: configRepo,
  } = org;
  const { repos, setRepos, searchTerm } = useContext(ReposContext);
  const orgRepos = repos.filter((repo) => repo.owner.id === org.id);

  return (
    <div className="organization" data-org-name={name}>
      <header className="organization-header">
        <h2 className="organization-header-title">{name}</h2>

        <Configuration
          orgId={id}
          enabled={configEnabled}
          repo={configRepo}
          repos={orgRepos}
        />
      </header>
      <section className="repo_listing">
        <Repos repos={orgRepos} searchTerm={searchTerm} setRepos={setRepos} />
      </section>
    </div>
  );
}

export default Organization;
