import React from 'react';

class TierPlan extends React.Component {
  get isCurrent() {
    return this.props.isCurrent;
  }

  get isNew() {
    return this.props.isNew;
  }

  render() {
    const { plan, isCurrent, isNew } = this.props;

    return(
      <div className={classNames(
          "plan",
          "plan-vertical",
          {"current": this.isCurrent},
          {"new": this.isNew}
        )}
      >
        { this.isCurrent &&
          (<div className="marker-wrapper">
            <span className="current-plan">Current Plan</span>
          </div>)
        }
        { this.isNew &&
          (<div className="marker-wrapper">
            <span className="new-plan">New Plan</span>
          </div>)
        }
        <div className="plan-divider">
          <h5 className="plan-title">{plan.name}</h5>
          <div className="plan-allowance">
            Up to <strong>{plan.upto}</strong> Repos
          </div>
        </div>
        <div className="plan-price">${plan.price} <small>month</small></div>
      </div>
    );
  }
}

module.exports = TierPlan;
