import React from 'react';

const UpdateAccountEmailMessage = ({ addressChanged }) => {
  if (addressChanged === null) {
    return null;
  } else if (addressChanged === true) {
    return (
      <p className="inline-flash inline-flash--success" data-role="flash">
        Email address updated!
      </p>
    );
  } else {
    return (
      <p className="inline-flash inline-flash--error">
        There was a problem updating your email. Please try again.
      </p>
    );
  }
};

export default UpdateAccountEmailMessage;
