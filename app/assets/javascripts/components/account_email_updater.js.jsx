class AccountEmailUpdater extends React.Component {
  state = {
    emailAddress: null,
    emailInput: null,
    addressChanged: null
  }

  componentWillMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": this.props.authenticity_token
      }
    });
  }

  onUpdateEmail(event) {
    event.preventDefault();

    $.ajax({
      url: "/account.json",
      type: "PUT",
      data: {billable_email: this.state.emailInput},
      dataType: "text",
      success: () => {
        this.setState({
          addressChanged: true,
          emailAddress: this.state.emailInput
        });
      },
      error: () => {
        this.setState({addressChanged: false});
      }
    });
  }

  render() {
    const { billable_email } = this.props;
    const placeholder = this.state.emailAddress || billable_email;

    return (
      <article className="account-details">
        <h3>Update account settings</h3>
        <form>
          <div className="form-group">
            <label>Email address for receipts</label>
            <input
              type="email"
              placeholder={placeholder}
              onChange={ event => this.setState({
                emailInput: event.target.value,
                addressChanged: null
              })}
            ></input>
            <AccountEmailUpdaterMessage
              addressChanged={this.state.addressChanged}
            />
          </div>
          <div className="form-actions">
            <button className="button-small" onClick={
              event => this.onUpdateEmail(event)
            }>
              Update Email
            </button>
          </div>
        </form>
      </article>
    );
  }
}
