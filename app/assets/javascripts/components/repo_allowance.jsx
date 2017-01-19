class RepoAllowance extends React.Component {
  render() {
    const { subscribedRepoCount, tierAllowance } = this.props;

    return(
      <div className="allowance">
        { "Private Repos " }
        <strong>
          <span data-role="subscribed-repo-count">{subscribedRepoCount}</span>
          { " / " }
          <span data-role="tier-allowance">{tierAllowance}</span>
        </strong>
      </div>
    )
  }
}

module.exports = RepoAllowance;
