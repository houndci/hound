import React, { useState } from 'react';
import classnames from 'classnames';

import { upgradeSubscription } from '../../modules/api';

const UpgradeSubscriptionLink = ({
  repoId,
  nextTier,
  userHasCard,
  marketplaceUpgradeUrl,
}) => {
  const [isDisabled, setIsDisabled] = useState(false);
  const upgradeWithNewCard = (token) => {
    upgradeSubscription(repoId, { card_token: token.id })
      .then(() => document.location.href = '/repos' );
  }
  const checkout = () => {
    const { stripePublishableKey, iconPath } = Hound.settings;

    return StripeCheckout.configure({
      key: stripePublishableKey,
      image: iconPath,
      token: upgradeWithNewCard,
    });
  }
  const showCreditCardForm = () => {
    const { userEmailAddress } = Hound.settings;
    const { price, title } = nextTier;

    checkout().open({
      name: `Upgrade to ${title}`,
      amount: price * 100,
      email: userEmailAddress,
      panelLabel: "{{amount}} per month",
      allowRememberMe: false
    });
  }
  const handleFailedUpgrade = (response) => {
    const subscriptionFailed = response &&
      response.errors &&
      response.errors.includes('There was an issue creating the subscription');

    if (subscriptionFailed) {
      showCreditCardForm();
    } else {
      setIsDisabled(false);

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

  const onClick = (e) => {
    e.preventDefault();

    if (marketplaceUpgradeUrl) {
      // improve this flow so we end up back at houndci.com
      window.open(marketplaceUpgradeUrl, '_blank');
    } else {
      setIsDisabled(true)

      if (userHasCard) {
        upgradeSubscription(repoId)
          .then(() => document.location.href = '/repos' )
          .catch((response) => handleFailedUpgrade(response.responseJSON));
      } else {
        showCreditCardForm();
      }
    }
  }

  const classNames = classnames(
    'repo-toggle',
    'tier-change-accept',
    { disabled: isDisabled },
  );

  return(
    <a href="" onClick={onClick} className={classNames}>Upgrade</a>
  );
};

export default UpgradeSubscriptionLink;
