import React, { useState } from 'react';

import { updateCustomerEmail } from '../../modules/api';
import UpdateAccountEmailMessage from './UpdateAccountEmailMessage';

const UpdateAccountEmail = ({ email }) => {
  const [billingEmail, setBillingEmail] = useState(email);
  const [isUpdated, setIsUpdated] = useState(false);
  const [isError, setIsError] = useState(false);
  const onChange = (event) => {
    setBillingEmail(event.target.value);
    setIsUpdated(false);
  };
  const onUpdateEmail = () => {
    if (billingEmail) {
      updateCustomerEmail(billingEmail)
        .then(() => setIsUpdated(true))
        .catch(() => setIsError(true));
    }
  };

  return (
    <article className="account-details">
      <h3>Update account settings</h3>
      <div className="form-group">
        <label>Email address for receipts</label>
        <input
          id="email_address"
          type="email"
          placeholder={email}
          onChange={onChange}
        />
        <UpdateAccountEmailMessage isUpdated={isUpdated} isError={isError}/>
      </div>
      <div className="form-actions">
        <button className="repo-toggle" onClick={onUpdateEmail}>
          Update Email
        </button>
      </div>
    </article>
  );
};

export default UpdateAccountEmail;
