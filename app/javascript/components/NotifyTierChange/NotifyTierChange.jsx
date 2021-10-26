import React from 'react';
import { find, findIndex } from 'lodash';

import UpgradeSubscriptionLink from './UpgradeSubscriptionLink';
import TierPlan from './TierPlan';

const NotifyTierChange = ({
  plans,
  repoId,
  repoName,
  nextPlan,
  hasCreditCard,
  marketplaceUpgradeUrl,
}) => {
  const currentPlanIndex = findIndex(plans, { current: true });
  const currentPlan = plans[currentPlanIndex];
  const isNewPlan = (plan) => plan === plans[currentPlanIndex + 1];

  return (
    <section className="tier-change-container">
      <aside className="tier-change-plans">
        <h3>Plans</h3>
        {plans.map((plan) => (
          <TierPlan
            isCurrent={plan.current}
            isNew={isNewPlan(plan)}
            key={plan.name}
            plan={plan}
          />
        ))}
      </aside>
      <div className="tier-change-content">
        <h1>Change of Plans</h1>
        <section className="tier-change-description">
          <p>
            <strong>
              Activating "{repoName}" will change the price you pay per month.
            </strong>
          </p>
          <p>Upgrade to continue with your new plan.</p>
        </section>

        <UpgradeSubscriptionLink
          nextTier={nextPlan}
          repoId={repoId}
          userHasCard={hasCreditCard}
          marketplaceUpgradeUrl={marketplaceUpgradeUrl}
        />
        <a className="tier-change-cancel" href="/repos">Cancel</a>
      </div>
    </section>
  );
};

export default NotifyTierChange;
