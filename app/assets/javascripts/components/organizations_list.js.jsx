import React from 'react';

import Organization from './organization.js';

class OrganizationsList extends React.Component {
  reposForOrg(org) {
    if (_.has(org, "id")) {
      return _.filter(this.props.repos, (repo) => {
        return repo.owner.id === org.id;
      });
    } else {
      return _.filter(this.props.repos, (repo) => {
        return this.orgName(repo.name) === org.name;
      });
    }
  }

  orgName(name) {
    return _.split(name, "/")[0];
  }

  render() {
    const {
      repos,
      onRepoClicked,
      filterTerm,
      isProcessingId,
      organizations,
    } = this.props;

    return (
      <ul className="organizations">
        {organizations.map( org => (
          <Organization
            name={org.name}
            key={org.id || org.name}
            repos={this.reposForOrg(org)}
            onRepoClicked={onRepoClicked}
            filterTerm={filterTerm}
            isProcessingId={isProcessingId}
          />
        ))}
      </ul>
    );
  }
}

module.exports = OrganizationsList;
