import React from 'react';

import * as Ajax from '../lib/ajax.js';

class UpgradeSubscriptionLink extends React.Component {
  componentWillMount() {
    $.ajaxSetup({ headers: { "X-XSRF-Token": this.props.authenticityToken } });
  }

  render() {
    const repoId = this.props.repoId;

    return(
      <a
        className="repo-toggle tier-change-accept"
        href="javascript:void(0);"
        onClick={() => Ajax.upgradeSubscription(repoId)}
      >Upgrade</a>
    );
  }
}

module.exports = UpgradeSubscriptionLink;
