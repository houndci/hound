import React from 'react';

import UpgradeSubscriptionLink from './upgrade_subscription_link.js';
import TierPlan from './tier_plan.js';

class NotifyTierChange extends React.Component {
  getCurrentPlan() {
    return this.getPlan(this.getCurrentPlanIndex());
  }

  getCurrentPlanIndex() {
    return _.findIndex(this.getPlans(), { current: true });
  }

  getCurrentPrice() {
    return this.getCurrentPlan().price;
  }

  getExtraCharge() {
    return this.getNewPrice() - this.getCurrentPrice();
  }

  getNewPlan() {
    return this.getPlan(this.getCurrentPlanIndex() + 1);
  }

  getNewPrice() {
    return this.getNewPlan().price;
  }

  getPlan(id) {
    return this.getPlans()[id];
  }

  getPlans() {
    return this.props.plans;
  }

  getTierUsage() {
    return this.getCurrentPlan().allowance;
  }

  isCurrentPlan(plan) {
    return plan === this.getCurrentPlan();
  }

  isNewPlan(plan) {
    return plan === this.getNewPlan();
  }

  renderTierPlans() {
    return (
      this.getPlans().map(plan => (
        <TierPlan
          isCurrent={this.isCurrentPlan(plan)}
          isNew={this.isNewPlan(plan)}
          key={plan.name}
          plan={plan}
        />
      ))
    );
  }

  render() {
    const { authenticity_token, repo_id, repo_name } = this.props;

    return (
      <section className="tier-change-container">
        <aside className="tier-change-plans">
          <h3>Plans</h3>
          {this.renderTierPlans()}
        </aside>
        <div className="tier-change-content">
          <h1>Pricing: Change of Plans</h1>
          <section className="tier-change-description">
            <div className="allowance large">
              Private Repos
              <strong>{this.getTierUsage()}/{this.getTierUsage()}</strong>
            </div>

            <p><strong>Activating "{repo_name}" will change the price you pay
            per month.</strong></p>

            <p>You'll be charged an extra ${this.getExtraCharge()} a month
            (${this.getNewPrice()} total).</p>

            <p>Upgrade to continue your activation of "{repo_name}"</p>
          </section>

          <UpgradeSubscriptionLink
            authenticityToken={authenticity_token}
            repoId={repo_id}
          />
          <a className="button tier-change-cancel" href="/repos">Cancel</a>
        </div>
      </section>
  );
  }
}

module.exports = NotifyTierChange;
