import React from 'react';

import UpdateAccountCreditCard from './UpdateAccountCreditCard';
import PlanDetails from './PlanDetails';
import UpdateAccountEmail from './UpdateAccountEmail';

const Account = ({ email, isAccountOwner, ...planProps }) => (
  <>
    <UpdateAccountCreditCard isAccountOwner={isAccountOwner} />
    <PlanDetails {...planProps} />
    {isAccountOwner && <UpdateAccountEmail email={email} />}
  </>
);

export default Account;
