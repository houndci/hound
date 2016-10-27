class TierChangeNotifier extends React.Component {
  render() {
    const {
      plans,
      repo_id,
      repo_name,
    } = this.props;

    const currentPlanIdx = _.findIndex(plans, {current: true});

    const currentPlan = plans[currentPlanIdx];
    const newPlan = plans[currentPlanIdx + 1];

    const tierUsage = currentPlan.upto;

    const extraCharge = newPlan.price - currentPlan.price;

    return (
      <section className="tier-change-container">
        <aside className="tier-change-plans">
          <h3>Plans</h3>
          {plans.map( plan => (
            <TierPlan
              plan={plan}
              isCurrent={plan === currentPlan}
              isNew={plan === newPlan}
            />
          ))}
        </aside>
        <div className="tier-change-content">
          <h1>Pricing: Change of Plans</h1>
          <section className="tier-change-description">
            <div className="allowance large">
              Private Repos <strong>{tierUsage}/{tierUsage}</strong>
            </div>
            <p>
              <strong>
                Activating "{repo_name}" will change the price you pay per month.<br/>
              </strong>
              You'll be charged an extra ${extraCharge} a month (${newPlan.price} total).
            </p>
            <p>
              Upgrade to continue or cancel to deactivate "{repo_name}"
            </p>
          </section>

          <a className="repo-toggle tier-change-accept" href="#">Upgrade</a>
          <a className="button tier-change-cancel" href="#">Cancel</a>
        </div>
      </section>
  );
  }
}
