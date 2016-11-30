import React from 'react';
import $ from 'jquery';

class UpdateAccountCreditCard extends React.Component {
  componentWillMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": this.props.authenticity_token
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
          <a href="#" className="update-card" onClick={this.onUpdateCreditCard.bind(this)}>
            <i className="fa fa-credit-card"></i>
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

module.exports = UpdateAccountCreditCard;
