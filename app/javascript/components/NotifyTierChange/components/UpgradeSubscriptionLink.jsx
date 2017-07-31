/*jshint esversion: 6 */

import React from 'react'
import * as Ajax from '../../../modules/Ajax'

export default class UpgradeSubscriptionLink extends React.Component {
  componentWillMount() {
    $.ajaxSetup({ headers: { "X-XSRF-Token": this.props.authenticityToken } })
  }

  upgradeWithNewCard(token) {
    const { repoId } = this.props
    Ajax.upgradeSubscription(repoId, { card_token: token.id })
  }

  checkout() {
    const { stripePublishableKey, iconPath } = Hound.settings

    return StripeCheckout.configure({
      key: stripePublishableKey,
      image: iconPath,
      token: (token) => this.upgradeWithNewCard(token),
    })
  }

  showCreditCardForm() {
    const { userEmailAddress } = Hound.settings
    const { price, title } = this.props.nextTier

    this.checkout().open({
      name: title,
      amount: price * 100,
      email: userEmailAddress,
      panelLabel: "{{amount}} per month",
      allowRememberMe: false
    })
  }

  handleClick() {
    const { repoId, userHasCard } = this.props

    if (userHasCard) {
      Ajax.upgradeSubscription(repoId)
    } else {
      this.showCreditCardForm()
    }
  }

  render() {
    return(
      <a
        className="repo-toggle tier-change-accept"
        href="javascript:void(0)"
        onClick={() => this.handleClick()}
      >Upgrade</a>
    )
  }
}
