import React from 'react';

const UpdateAccountEmailMessage = ({ isUpdated, isError }) => {
  if (isError) {
    return (
      <p className="inline-flash inline-flash--error">
        There was a problem updating your email. Please try again.
      </p>
    );
  } else if (isUpdated) {
    return (
      <p className="inline-flash inline-flash--success" data-role="flash">
        Email address updated!
      </p>
    );
  } else {
    return null;
  }
};

export default UpdateAccountEmailMessage;
