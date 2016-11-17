class UpgradeSubscriptionLink extends React.Component {
  componentWillMount() {
    $.ajaxSetup({ headers: { "X-XSRF-Token": this.props.authenticityToken } });
  }

  upgradeSubscription(id) {
    return $.ajax({
      dataType: "json",
      type: "PUT",
      url: `/repos/${id}/subscription.json`,
      success: () => {
        document.location.href = "/repos";
      }
    });
  }

  render() {
    const repoId = this.props.repoId;

    return(
      <a
        className="repo-toggle tier-change-accept"
        href="javascript:void(0);"
        onClick={() => this.upgradeSubscription(repoId)}
      >Upgrade</a>
    );
  }
}
