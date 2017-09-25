import React from 'react';
import $ from 'jquery';

import { getCSRFfromHead } from '../../../modules/Utils';
import UpdateAccountEmailMessage from './UpdateAccountEmailMessage';

export default class UpdateAccountEmail extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      emailAddress: null,
      emailInput: null,
      addressChanged: null
    };
  }

  componentWillMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": getCSRFfromHead()
      }
    });
  }

  onUpdateEmail(event) {
    event.preventDefault();

    if (this.state.emailInput == null) {
      return;
    }

    $.ajax({
      url: "/account.json",
      type: "PUT",
      data: { billable_email: this.state.emailInput },
      dataType: "text",
      success: () => {
        this.setState({ addressChanged: true });
      },
      error: () => {
        this.setState({ addressChanged: false });
      }
    });
  }

  render() {
    const placeholder = this.state.emailAddress || this.props.billable_email;

    return (
      <article className="account-details">
        <h3>Update account settings</h3>
        <form>
          <div className="form-group">
            <label>Email address for receipts</label>
            <input
              id="email_address"
              type="email"
              placeholder={placeholder}
              onChange={ event => this.setState({
                emailInput: event.target.value,
                addressChanged: null
              })}
            ></input>
            <UpdateAccountEmailMessage
              addressChanged={this.state.addressChanged}
            />
          </div>
          <div className="form-actions">
            <button
              className="button-small"
              onClick={(event) => this.onUpdateEmail(event)}
            >
              Update Email
            </button>
          </div>
        </form>
      </article>
    );
  }
}
