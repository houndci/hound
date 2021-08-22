import classNames from 'classnames';
import React from 'react';

export default class TierPlan extends React.Component {
  getIsCurrent() {
    return this.props.isCurrent;
  }

  getIsNew() {
    return this.props.isNew;
  }

  renderCurrentPlan() {
    if (this.getIsCurrent()) {
      return (
        <div className="plan-marker__wrapper">
          <span className="plan-marker plan-marker--current">Current Plan</span>
        </div>
      );
    }
  }

  renderNewPlan() {
    if (this.getIsNew()) {
      return (
        <div className="plan-marker__wrapper">
          <span className="plan-marker plan-marker--new">New Plan</span>
        </div>
      );
    }
  }

  render() {
    const plan = this.props.plan;

    let allowance = null;

    if (plan.allowance > 0) {
      allowance = <div className="plan-allowance">
        Up to <strong>{plan.allowance.toLocaleString()}</strong> Reviews
      </div>;
    } else {
      allowance = <div className="plan-allowance">
        Unlimited
      </div>;
    }

    return(
      <div className={
        classNames(
          "plan",
          "plan-vertical",
          { "current": this.getIsCurrent() },
          { "new": this.getIsNew() }
        )
      }>
        {this.renderCurrentPlan()}
        {this.renderNewPlan()}
        <div className="plan-divider">
          <h5 className="plan-title">{plan.name}</h5>
          {allowance}
        </div>
        <div className="plan-price">${plan.price} <small>month</small></div>
      </div>
    );
  }
}
