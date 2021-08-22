import React from 'react';

export default class UpgradeSubscriptionLink extends React.Component {
  constructor(props) {
    super(props);

    this.state = { disabled: false };
  }

  componentDidMount() {
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
    const subscriptionFailed = response &&
      response.errors &&
      response.errors.includes("There was an issue creating the subscription");

    if (subscriptionFailed) {
      this.showCreditCardForm();
    } else {
      this.setState({ disabled: false });

      // There's probably a more elegant way to do this
      //
      // Intercom doesn't seem available when component is set up
      // to include in props
      if (window.Intercom) {
        window.Intercom(
          "showNewMessage",
          "I cannot upgrade and activate my repo. Please help!"
        );
      } else {
        alert("Oh no, upgrading and activating a repo failed. Please contact us!");
      }
    }
  }

  handleClick = (e) => {
    e.preventDefault();

    if (this.props.marketplaceUpgradeUrl) {
      // improve this flow so we end up back at houndci.com
      window.open(this.props.marketplaceUpgradeUrl, '_blank');
    } else {
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
  }

  render() {
    return(
      <a
        href=""
        className={
          this.state.disabled ?
            "repo-toggle tier-change-accept disabled" :
            "repo-toggle tier-change-accept"
        }
        onClick={this.handleClick}
      >Upgrade</a>
    );
  }
}
