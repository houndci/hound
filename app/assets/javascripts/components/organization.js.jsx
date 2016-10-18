class Organization extends React.Component {
  render() {
    const {
      data,
      onRepoClicked,
      isProcessingId,
      repos,
      filterTerm,
    } = this.props;

    return (
      <div className="organization" data-org-name={data.name}>
        <header className="organization-header">
          <h2 className="organization-header-title">{data.name}</h2>
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
