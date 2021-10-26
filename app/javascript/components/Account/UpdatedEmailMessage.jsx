import React from 'react';

const UpdatedEmailMessage = ({ isUpdated, isError }) => (
  <div className="updated-email-message">
    {isError && (
      <p className="inline-flash inline-flash--error">
        There was a problem updating your email. Please try again.
      </p>
    )}
    {!isError && isUpdated && (
      <p className="inline-flash inline-flash--success" data-role="flash">
        Email address updated!
      </p>
    )}
  </div>
);

export default UpdatedEmailMessage;
