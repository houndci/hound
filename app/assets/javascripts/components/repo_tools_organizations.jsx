class RepoToolsOrganizations extends React.Component {
  render() {
    const { organizations } = this.props;

    return (
      <div className="repo-tools-org dropdown">
        <i className="fa fa-caret-down"></i>
        <select className="quick-jump">
          <option disabled>Quick jump to organization</option>
          {organizations.map( org => (
            <option key={org.id} value={"div[data-org-name='" + org.name + "']"}>{org.name}</option>
          ))}
        </select>
      </div>
    )
  }
}

module.exports = RepoToolsOrganizations;
