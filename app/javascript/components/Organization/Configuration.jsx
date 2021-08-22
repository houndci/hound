import React from 'react';
import classNames from 'classnames';
import 'object-assign-shim';

import { updateOwner } from '../../modules/api';

class Configuration extends React.Component {
  constructor(props) {
    super(props);

    const repo = props.repo || "";

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
    const params = {
      config_enabled: this.state.enabled,
      config_repo: this.state.repo,
      ...options,
    };

    this.setState({ configUpdated: false });
    updateOwner(this.props.id, params).then(() =>
      this.setState({ configUpdated: true })
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
            <RepoOptions
              repos={this.props.repos}
              selectedRepo={this.state.repo}
            />
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

  render() {
    const switchId = `toggle-${this.props.id}`;

    return (
      <div className="organization-header-config">
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

        {this.renderRepoSelect()}
      </div>
    );
  }
}


const RepoOptions = ({ repos, selectedRepo }) => {
  let repoNames = repos.map((repo) => repo.name);
  if (!repoNames.includes(selectedRepo)) {
    repoNames = [selectedRepo, ...repoNames];
  }

  return (
    <>
      {repoNames.map((name) =>
        <option key={name} value={name}>{name}</option>
      )}
    </>
  );
};

export default Configuration;
