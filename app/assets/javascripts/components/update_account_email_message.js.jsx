class UpdateAccountEmailMessage extends React.Component {
  render() {
    if (this.props.addressChanged === null) {
      return null;
    } else if (this.props.addressChanged === true) {
      return (
        <p className="inline-flash inline-flash--success">
          <i className="fa fa-check">
            Email address updated!
          </i>
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
