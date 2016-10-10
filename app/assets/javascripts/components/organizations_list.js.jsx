class OrganizationsList extends React.Component {
  reposForOrg(org) {
    return _.filter(this.props.repos, (repo) => {
      return repo.owner.id === org.id;
    });
  }

  render() {
    const {
      repos,
      onRepoClicked,
      filterTerm,
      isProcessingId,
    } = this.props;
    return (
      <ul className="organizations">
        {this.props.organizations.map( (org) => (
          <Organization
            data={org}
            key={org.id}
            repos={(repos && this.reposForOrg(org)) || null}
            onRepoClicked={onRepoClicked}
            filterTerm={filterTerm}
            isProcessingId={isProcessingId}
          />
        ))}
      </ul>
    );
  }
}
