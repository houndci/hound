import React from "react";
import classNames from "classnames";
import $ from "jquery";

import "object-assign-shim";

import * as Ajax from "../../../../modules/Ajax";

export default class OrganizationConfiguration extends React.Component {
  constructor(props) {
    super(props);

    let repo = "";

    if (props.repo) {
      repo = props.repo;
    }

    this.state = {
      configUpdated: false,
      enabled: !!props.enabled,
      repo
    };
  }

  setEnabled(enabled) {
    this.setState({ enabled });
    this.updateOwner({ config_enabled: enabled });
  }

  setRepo(repo) {
    this.setState({ repo });
    this.updateOwner({ config_repo: repo });
  }

  handleChange(event) {
    this.setRepo(event.target.value);
  }

  toggle() {
    const enabled = !this.state.enabled;
    this.setEnabled(enabled);
  }

  updateOwner(options) {
    const currentState = {
      config_enabled: this.state.enabled,
      config_repo: this.state.repo
    };

    this.setState({ configUpdated: false });
    Ajax.updateOwner(this.props.id, { ...currentState, ...options }).then(() =>
      this.setState({ configUpdated: true })
    );
  }

  renderConfigSwitch() {
    const switchId = `toggle-${this.props.id}`;

    return (
      <div className="organization-header-toggle">
        <span className="organization-header-label">
          Use organization-wide config
        </span>

        <input
          id={switchId}
          checked={this.state.enabled}
          className="organization-header-toggle-input"
          onChange={() => this.toggle()}
          type="checkbox"
          name="toggle"
        />

        <label className="toggle-switch" htmlFor={switchId} />
      </div>
    );
  }

  renderRepoSelect() {
    if (this.state.enabled) {
      return (
        <div className="organization-header-source">
          <span className="organization-header-label">Use .hound.yml from</span>
          <select
            className="organization-header-select"
            onChange={event => this.handleChange(event)}
            value={this.state.repo}
          >
            {this.renderRepoOptions()}
          </select>
          <div className="inline-flash--success config-enabled">
            {this.state.configUpdated &&
              <span data-role="config-saved">&#10004;</span>}
          </div>
        </div>
      );
    } else {
      return null;
    }
  }

  renderRepoOptions() {
    let repoOptions = this.props.repos.map(repo =>
      <option key={repo.id} value={repo.name}>
        {repo.name}
      </option>
    );

    repoOptions.unshift(<option key="-1">None</option>);

    return repoOptions;
  }

  renderReadOnlyConfigMessage() {
    let message;

    if (this.state.enabled && this.state.repo) {
      message = `Using organization-wide config from ${this.state.repo}`;
    } else {
      message = 'Organization-wide config is disabled (only Organization owners can activate)';
    }

    return (
      <div className="organization-header-toggle">
        <span className="organization-header-label">{message}</span>
      </div>
    );
  }

  render() {
    if (this.props.userIsOrgOwner) {
      return (
        <div className="organization-header-config">
          {this.renderConfigSwitch()}

          {this.renderRepoSelect()}
        </div>
      );
    } else {
      return (
        <div className="organization-header-config">
          {this.renderReadOnlyConfigMessage()}
        </div>
      );
    }
  }
}
