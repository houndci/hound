import React from 'react';

const PlanDetails = ({ plan, monthlyCost, buildsNumber }) => (
  <table className="itemized-receipt">
    <thead>
      <tr>
        <th>Plan</th>
        <th>Reviews in the last month</th>
        <th>Price</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>{plan}</td>
        <td>{buildsNumber}</td>
        <td>{monthlyCost}</td>
      </tr>
    </tbody>
  </table>
);

export default PlanDetails;
