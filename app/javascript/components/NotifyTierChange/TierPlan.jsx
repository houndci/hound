import React from 'react';
import classnames from 'classnames';

const TierPlan = ({ plan, isCurrent, isNew }) => {
  const classNames = classnames(
    "plan",
    "plan-vertical",
    { "current": isCurrent },
    { "new": isNew }
  );

  return (
    <div className={classNames}>
      {isCurrent && (
        <div className="plan-marker__wrapper">
          <span className="plan-marker plan-marker--current">Current Plan</span>
        </div>
      )}
      {isNew && (
        <div className="plan-marker__wrapper">
          <span className="plan-marker plan-marker--new">New Plan</span>
        </div>
      )}
      <div className="plan-divider">
        <h5 className="plan-title">{plan.name}</h5>
        <div className="plan-allowance">
          Up to <strong>{plan.allowance.toLocaleString()}</strong> Reviews
        </div>
      </div>
      <div className="plan-price">${plan.price} <small>month</small></div>
    </div>
  );
};

export default TierPlan;
