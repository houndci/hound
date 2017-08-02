/*jshint esversion: 6 */

import React from 'react';

export default class RepoToolsSearch extends React.Component {
  render() {
    return (
      <div className="repo-tools-search">
        <input
          className="repo-search-tools-input"
          placeholder={Hound.settings.searchPlaceholder}
          type="text"
          onChange={this.props.onSearchInput}
        />
      </div>
    );
  }
}
