import React from 'react';

import Configuration from './Configuration';
import Repos from './Repos';

const Organization = ({ org, repos, searchTerm }) => {
  const {
    id,
    name,
    config_enabled: configEnabled,
    config_repo: configRepo,
  } = org;

  return (
    <div className="organization" data-org-name={name}>
      <header className="organization-header">
        <h2 className="organization-header-title">{name}</h2>

        <Configuration
          id={id}
          enabled={configEnabled}
          repo={configRepo}
          repos={repos}
        />
      </header>
      <section className="repo_listing">
        <Repos repos={repos} searchTerm={searchTerm} />
      </section>
    </div>
  );
}

export default Organization;
