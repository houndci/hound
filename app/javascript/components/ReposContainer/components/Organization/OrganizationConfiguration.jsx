/*jshint esversion: 6 */

import React from 'react';
import classNames from 'classnames';
import $ from 'jquery';

import 'object-assign-shim';

import * as Ajax from '../../../../modules/Ajax';

export default class OrganizationConfiguration extends React.Component {
  constructor(props) {
    super(props);

    let repo = '';

    if (props.repo) {
      repo = props.repo;
    }

    this.state = { enabled: !!props.enabled, repo };
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
      config_repo: this.state.repo,
    };
    Ajax.updateOwner(this.props.id, Object.assign({}, currentState, options));
  }

  renderRepoSelect() {
    if (this.state.enabled) {
      return (
        <div className='organization-header-source'>
          <span className='organization-header-label'>
            Use .hound.yml from
          </span>

          <select
            className='organization-header-select'
            onChange={(event) => this.handleChange(event)}
            value={this.state.repo}
          >
            {this.renderRepoOptions()}
          </select>
        </div>
      );
    } else {
      return null;
    }
  }

  renderRepoOptions() {
    return (
      this.props.repos.map(repo => (
        <option key={repo.id} value={repo.name}>{repo.name}</option>
      ))
    );
  }

  render() {
    const switchId = `toggle-${this.props.id}`;
    return (
      <div className='organization-header-config'>
        <div className='organization-header-toggle'>
          <span className='organization-header-label'>
            Use organization-wide config
          </span>

          <input
            id={switchId}
            checked={this.state.enabled}
            className='organization-header-toggle-input'
            onChange={() => this.toggle()}
            type='checkbox'
            name='toggle'
          />

          <label className='toggle-switch' htmlFor={switchId} />
        </div>

        {this.renderRepoSelect()}
      </div>
    );
  }
}
