/*jshint esversion: 6 */

import React from 'react';

export default class UpdateAccountEmailMessage extends React.Component {
  render() {
    if (this.props.addressChanged === null) {
      return null;
    } else if (this.props.addressChanged === true) {
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
  }
}
