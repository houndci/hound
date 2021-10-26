import React, { useState } from 'react';

import { updateCustomerEmail } from '../../modules/api';
import UpdatedEmailMessage from './UpdatedEmailMessage';

const UpdateAccountEmail = ({ email }) => {
  const [billingEmail, setBillingEmail] = useState(email);
  const [isUpdated, setIsUpdated] = useState(false);
  const [isError, setIsError] = useState(false);
  const onChange = (event) => {
    setBillingEmail(event.target.value);
    setIsUpdated(false);
  };
  const onUpdateEmail = (event) => {
    event.preventDefault();
    const newEmail = event.target.email.value;
    if (email) {
      updateCustomerEmail(newEmail)
        .then(() => setIsUpdated(true))
        .catch(() => setIsError(true));
    }
  };

  return (
    <article className="account-details">
      <h3>Update account settings</h3>
      <form onSubmit={onUpdateEmail}>
        <div className="form-group">
          <label>Email address for receipts</label>
          <input name="email" type="email" placeholder={email} />
        </div>
        <div className="form-actions">
          <button className="repo-toggle">
            Update Email
          </button>
        </div>
        <UpdatedEmailMessage isUpdated={isUpdated} isError={isError} />
      </form>
    </article>
  );
};

export default UpdateAccountEmail;
