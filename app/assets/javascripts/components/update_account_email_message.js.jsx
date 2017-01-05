class UpdateAccountEmailMessage extends React.Component {
  render() {
    if (this.props.addressChanged === null) {
      return null;
    } else if (this.props.addressChanged === true) {
      return (
        <p className="inline-flash inline-flash--success" data-role="flash">
          <i className="fa fa-check"></i>
          Email address updated!
        </p>
      );
    } else {
      return (
        <p className="inline-flash inline-flash--error">
          <i className="fa fa-exclamation-circle">
            There was a problem updating your email. Please try again.
          </i>
        </p>
      );
    }
  }
}

module.exports = UpdateAccountEmailMessage;
