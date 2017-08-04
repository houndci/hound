import React from 'react';
import $ from 'jquery';

import { getCSRFfromHead } from '../../../modules/Utils';

export default class UpdateAccountCreditCard extends React.Component {
  componentWillMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": getCSRFfromHead()
      }
    });
  }

  updateCustomerCreditCard(stripeToken) {
    $.ajax({
      url: "/credit_card.json",
      type: "PUT",
      data: { card_token: stripeToken.id },
      dataType: "json"
    });
  }

  onUpdateCreditCard(event) {
    event.preventDefault();

    StripeCheckout.configure({
      key: Hound.settings.stripePublishableKey,
      image: Hound.settings.iconPath,
      token: this.updateCustomerCreditCard
    }).open({
      email: $("input[type=email]").attr("placeholder"),
      panelLabel: "Update Card",
      allowRememberMe: false
    });
  }

  render() {
    if (this.props.stripe_customer_id_present) {
      return (
        <h3>
          Monthly Billing
          <a href="#" className="update-card" onClick={(event) =>this.onUpdateCreditCard(event)}>
            Update Credit Card
          </a>
        </h3>
      );
    } else {
      return (
        <h3>Monthly Billing</h3>
      );
    }
  }
}
