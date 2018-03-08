import React from 'react';

import OrganizationConfiguration from "./Organization/OrganizationConfiguration";
import RepoList from './Organization/RepoList';

export default class Organization extends React.Component {
  render() {
    const {
      name,
      onRepoClicked,
      isProcessingId,
      repos,
      configEnabled,
      configRepo,
      filterTerm,
      ownerId,
      userIsOrgOwner
    } = this.props;

    return (
      <div className="organization" data-org-name={name}>
        <header className="organization-header">
          <h2 className="organization-header-title">{name}</h2>

          <OrganizationConfiguration
            enabled={configEnabled}
            id={ownerId}
            repo={configRepo}
            repos={repos}
            userIsOrgOwner={userIsOrgOwner}
          />
        </header>
        <section className="repo_listing">
          <RepoList
            repos={repos}
            onRepoClicked={onRepoClicked}
            isProcessingId={isProcessingId}
            filterTerm={filterTerm}
          />
        </section>
      </div>
    );
  }
}
