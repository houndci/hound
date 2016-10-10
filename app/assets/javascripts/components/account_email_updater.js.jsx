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

  onUpdateEmail(evt) {
    evt.preventDefault();

    $.ajax({
      url: `/account.json`,
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
    return (
      <article className="account-details">
        <h3>Update account settings</h3>
        <form>
          <div className="form-group">
            <label>Email address for receipts</label>
            <input
              type="email"
              placeholder={this.state.emailAddress || this.props.billable_email}
              onChange={(evt) => this.setState({emailInput: evt.target.value, addressChanged: null})}
            ></input>
            <AccountEmailUpdaterMessage addressChanged={this.state.addressChanged} />
          </div>
          <div className="form-actions">
            <button className="button-small" onClick={(evt) => this.onUpdateEmail(evt)}>
              Update Email
            </button>
          </div>
        </form>
      </article>
    );
  }
}
