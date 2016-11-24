import React from 'react';

import RepoList from './repo_list.js';

class Organization extends React.Component {
  render() {
    const {
      name,
      onRepoClicked,
      isProcessingId,
      repos,
      filterTerm,
    } = this.props;

    return (
      <div className="organization" data-org-name={name}>
        <header className="organization-header">
          <h2 className="organization-header-title">{name}</h2>
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

module.exports = Organization;
