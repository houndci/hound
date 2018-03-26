import React from 'react';
import $ from 'jquery';

import * as Ajax from '../../../modules/Ajax';
import { getCSRFfromHead } from '../../../modules/Utils';

export default class UpgradeSubscriptionLink extends React.Component {
  constructor(props) {
    super(props);

    this.state = { disabled: false };
  }

  componentWillMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": getCSRFfromHead()
      }
    });
  }

  upgradeWithNewCard(token) {
    const { repoId } = this.props;
    Ajax.upgradeSubscription(repoId, { card_token: token.id });
  }

  checkout() {
    const { stripePublishableKey, iconPath } = Hound.settings;

    return StripeCheckout.configure({
      key: stripePublishableKey,
      image: iconPath,
      token: (token) => this.upgradeWithNewCard(token),
    });
  }

  showCreditCardForm() {
    const { userEmailAddress } = Hound.settings;
    const { price, title } = this.props.nextTier;

    this.checkout().open({
      name: `Upgrade to ${title}`,
      amount: price * 100,
      email: userEmailAddress,
      panelLabel: "{{amount}} per month",
      allowRememberMe: false
    });
  }

  handleFailedUpgrade(response) {
    const { intercom } = this.props;

    const subscriptionFailed = response &&
      response.errors &&
      response.errors.includes("There was an issue creating the subscription");

    if (subscriptionFailed) {
      this.showCreditCardForm();
    } else {
      this.setState({ disabled: false });

      if (intercom) {
        intercom(
          "showNewMessage",
          "I cannot upgrade and activate my repo. Please help!"
        );
      } else {
        alert("Oh no, upgrading and activating the repo failed.");
      }
    }
  }

  handleClick() {
    this.setState({ disabled: true });

    const { repoId, userHasCard } = this.props;

    if (userHasCard) {
      Ajax.upgradeSubscription(repoId).fail(
        (response) => this.handleFailedUpgrade(response.responseJSON)
      );
    } else {
      this.showCreditCardForm();
    }
  }

  render() {
    return(
      <a
        className={
          this.state.disabled ?
            "repo-toggle tier-change-accept disabled" :
            "repo-toggle tier-change-accept"
        }
        href="javascript:void(0);"
        onClick={() => this.handleClick()}
      >Upgrade</a>
    );
  }
}
