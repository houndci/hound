import React from 'react';

const PlanAllowance = ({ subscribedRepoCount, tierAllowance }) => (
  <div className="allowance">
    Private Repos
    <strong>
      <span data-role="subscribed-repo-count">{subscribedRepoCount}</span>
      /
      <span data-role="tier-allowance">{tierAllowance}</span>
    </strong>
  </div>
);

export default PlanAllowance;
