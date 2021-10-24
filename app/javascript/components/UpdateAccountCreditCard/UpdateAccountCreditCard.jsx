import React from 'react';

import { updateCustomerCreditCard } from '../../modules/api';

const UpdateAccountCreditCard = (props) => {
  const onUpdateCreditCard = (event) => {
    event.preventDefault();

    StripeCheckout.configure({
      key: Hound.settings.stripePublishableKey,
      image: Hound.settings.iconPath,
      token: (token) => updateCustomerCreditCard(token.id),
    }).open({
      email: $("input[type=email]").attr("placeholder"),
      panelLabel: "Update Card",
      allowRememberMe: false,
    });
  }

  return (
    <h3>
      Monthly Billing
      {props.stripe_customer_id_present && (
        <a href="#" className="update-card" onClick={onUpdateCreditCard}>
          Update Credit Card
        </a>
      )}
    </h3>
  );
}

export default UpdateAccountCreditCard;
